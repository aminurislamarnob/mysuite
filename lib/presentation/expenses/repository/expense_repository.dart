import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/people/people_repository.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(
    ref.watch(databaseProvider),
    ref.watch(peopleRepositoryProvider),
  );
});

/// Transaction kinds, mirroring `Expenses.kind`.
class TxKind {
  static const expense = 0;
  static const income = 1;
  static const transfer = 2;
  static const lend = 3;
  static const borrow = 4;
  static const repayment = 5;

  /// Lending, borrowing and repaying move money but are neither spending nor
  /// earning, so reports and budgets leave them out.
  static bool isLoan(int kind) =>
      kind == lend || kind == borrow || kind == repayment;

  /// The principal row of a loan, which lives and dies with the loan itself.
  static bool isLoanPrincipal(int kind) => kind == lend || kind == borrow;
}

/// `Loans.direction` values.
class LoanDirection {
  /// They owe me.
  static const lent = 0;

  /// I owe them.
  static const borrowed = 1;
}

class ExpenseRepository {
  final AppDatabase _db;
  final PeopleRepository _people;

  ExpenseRepository(this._db, this._people);

  // --- Accounts ------------------------------------------------------------

  Stream<List<Account>> watchAccounts() => (_db.select(
    _db.accounts,
  )..where((t) => t.isArchived.equals(false))).watch();

  /// Archived accounts included, so old rows can still name their account.
  Stream<List<Account>> watchAllAccounts() => _db.select(_db.accounts).watch();

  Future<List<Account>> accounts() => (_db.select(
    _db.accounts,
  )..where((t) => t.isArchived.equals(false))).get();

  Future<int> createAccount(
    String name,
    String type,
    double balance,
    int color,
  ) => _db
      .into(_db.accounts)
      .insert(
        AccountsCompanion.insert(
          name: name,
          type: Value(type),
          balance: Value(balance),
          color: Value(color),
        ),
      );

  Future<void> updateAccount(
    int id, {
    String? name,
    String? type,
    int? color,
  }) => (_db.update(_db.accounts)..where((t) => t.id.equals(id))).write(
    AccountsCompanion(
      name: name == null ? const Value.absent() : Value(name),
      type: type == null ? const Value.absent() : Value(type),
      color: color == null ? const Value.absent() : Value(color),
    ),
  );

  /// Archiving keeps the account's history; its balance simply stops counting
  /// towards the total.
  Future<void> setAccountArchived(int id, bool archived) =>
      (_db.update(_db.accounts)..where((t) => t.id.equals(id))).write(
        AccountsCompanion(isArchived: Value(archived)),
      );

  Future<void> deleteAccount(int id) =>
      (_db.delete(_db.accounts)..where((t) => t.id.equals(id))).go();

  // --- Categories ----------------------------------------------------------

  Stream<List<ExpenseCategory>> watchCategories({bool? income}) {
    final q = _db.select(_db.expenseCategories)
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.id),
      ]);
    if (income != null) q.where((t) => t.isIncome.equals(income));
    return q.watch();
  }

  Future<List<ExpenseCategory>> categories() =>
      (_db.select(_db.expenseCategories)..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.id),
          ]))
          .get();

  Future<int> createCategory(
    String name,
    String icon,
    int color, {
    bool isIncome = false,
  }) async {
    final last = _db.expenseCategories.sortOrder.max();
    final q = _db.selectOnly(_db.expenseCategories)..addColumns([last]);
    final next = ((await q.getSingle()).read(last) ?? -1) + 1;
    return _db
        .into(_db.expenseCategories)
        .insert(
          ExpenseCategoriesCompanion.insert(
            name: name,
            icon: Value(icon),
            color: Value(color),
            isIncome: Value(isIncome),
            sortOrder: Value(next),
          ),
        );
  }

  Future<void> updateCategory(
    int id, {
    String? name,
    String? icon,
    int? color,
  }) =>
      (_db.update(_db.expenseCategories)..where((t) => t.id.equals(id))).write(
        ExpenseCategoriesCompanion(
          name: name == null ? const Value.absent() : Value(name),
          icon: icon == null ? const Value.absent() : Value(icon),
          color: color == null ? const Value.absent() : Value(color),
        ),
      );

  /// Persists a new order; [ids] is the full list in display order.
  Future<void> reorderCategories(List<int> ids) => _db.batch((b) {
    for (var i = 0; i < ids.length; i++) {
      b.update(
        _db.expenseCategories,
        ExpenseCategoriesCompanion(sortOrder: Value(i)),
        where: (t) => t.id.equals(ids[i]),
      );
    }
  });

  Future<int> categoryTransactionCount(int categoryId) async {
    final q = _db.selectOnly(_db.expenses)
      ..addColumns([countAll()])
      ..where(_db.expenses.categoryId.equals(categoryId));
    return (await q.getSingle()).read(countAll()) ?? 0;
  }

  /// Deletes a category. Its transactions and recurring bills move to
  /// [reassignTo]; its budgets are dropped, since they capped something that
  /// no longer exists. A category with history cannot be deleted without a
  /// destination.
  Future<void> deleteCategory(int id, {int? reassignTo}) async {
    await _db.transaction(() async {
      if (reassignTo == null && await categoryTransactionCount(id) > 0) {
        throw StateError('Category $id has transactions; reassign them.');
      }
      if (reassignTo != null) {
        await (_db.update(_db.expenses)..where((t) => t.categoryId.equals(id)))
            .write(ExpensesCompanion(categoryId: Value(reassignTo)));
        await (_db.update(_db.recurringExpenses)
              ..where((t) => t.categoryId.equals(id)))
            .write(RecurringExpensesCompanion(categoryId: Value(reassignTo)));
      }
      await (_db.delete(
        _db.budgets,
      )..where((t) => t.categoryId.equals(id))).go();
      await (_db.delete(
        _db.expenseCategories,
      )..where((t) => t.id.equals(id))).go();
    });
  }

  // --- Transactions --------------------------------------------------------

  Stream<List<Expense>> watchRecent({int limit = 20}) =>
      (_db.select(_db.expenses)
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ])
            ..limit(limit))
          .watch();

  Stream<List<Expense>> watchBetween(DateTime from, DateTime to) =>
      (_db.select(_db.expenses)
            ..where(
              (t) =>
                  t.date.isBiggerOrEqualValue(from) &
                  t.date.isSmallerThanValue(to),
            )
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .watch();

  Future<List<Expense>> between(DateTime from, DateTime to) =>
      (_db.select(_db.expenses)..where(
            (t) =>
                t.date.isBiggerOrEqualValue(from) &
                t.date.isSmallerThanValue(to),
          ))
          .get();

  Future<Expense?> transaction(int id) => (_db.select(
    _db.expenses,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Records a transaction and moves the money, in one transaction so a
  /// failure can never leave a balance out of step with its ledger.
  Future<int> addTransaction({
    required double amount,
    required int accountId,
    int? categoryId,
    int kind = TxKind.expense,
    int? transferAccountId,
    int? personId,
    int? loanId,
    String? note,
    String? receiptPath,
    DateTime? date,
  }) async {
    return _db.transaction(() async {
      final id = await _db
          .into(_db.expenses)
          .insert(
            ExpensesCompanion.insert(
              amount: amount,
              accountId: accountId,
              categoryId: Value(categoryId),
              kind: Value(kind),
              transferAccountId: Value(transferAccountId),
              personId: personId ?? await _people.selfId(),
              loanId: Value(loanId),
              note: Value(note),
              receiptPath: Value(receiptPath),
              date: Value(date ?? DateTime.now()),
            ),
          );
      await _apply(await _row(id), 1);
      if (loanId != null) await _refreshSettled(loanId);
      return id;
    });
  }

  /// Rewrites a transaction, undoing the old row's effect on the balances
  /// before applying the new one. Absent arguments keep their value.
  Future<void> updateTransaction(
    int id, {
    double? amount,
    int? accountId,
    Value<int?> categoryId = const Value.absent(),
    int? kind,
    Value<int?> transferAccountId = const Value.absent(),
    int? personId,
    Value<String?> note = const Value.absent(),
    DateTime? date,
  }) async {
    await _db.transaction(() async {
      final old = await _row(id);
      await _apply(old, -1);
      await (_db.update(_db.expenses)..where((t) => t.id.equals(id))).write(
        ExpensesCompanion(
          amount: amount == null ? const Value.absent() : Value(amount),
          accountId: accountId == null
              ? const Value.absent()
              : Value(accountId),
          categoryId: categoryId,
          kind: kind == null ? const Value.absent() : Value(kind),
          transferAccountId: transferAccountId,
          personId: personId == null ? const Value.absent() : Value(personId),
          note: note,
          date: date == null ? const Value.absent() : Value(date),
        ),
      );
      final fresh = await _row(id);
      await _apply(fresh, 1);
      if (fresh.loanId != null) await _refreshSettled(fresh.loanId!);
    });
  }

  /// Deletes a transaction and reverses its effect on the account balances.
  /// Returns the row so the caller can offer to [restoreTransaction] it.
  /// Deleting a loan's principal removes the loan and its repayments too.
  Future<Expense?> deleteTransaction(int id) async {
    return _db.transaction(() async {
      final tx = await transaction(id);
      if (tx == null) return null;
      if (tx.loanId != null && TxKind.isLoanPrincipal(tx.kind)) {
        await deleteLoan(tx.loanId!);
        return tx;
      }
      await _apply(tx, -1);
      await (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
      if (tx.loanId != null) await _refreshSettled(tx.loanId!);
      return tx;
    });
  }

  /// Puts back a row handed out by [deleteTransaction], id and all, so any
  /// receipt or loan link it carried still holds.
  Future<void> restoreTransaction(Expense tx) async {
    await _db.transaction(() async {
      await _db.into(_db.expenses).insert(tx.toCompanion(false));
      await _apply(tx, 1);
      if (tx.loanId != null) await _refreshSettled(tx.loanId!);
    });
  }

  Future<Expense> _row(int id) =>
      (_db.select(_db.expenses)..where((t) => t.id.equals(id))).getSingle();

  /// Moves the money for [tx]; [sign] is 1 to apply it and -1 to reverse it.
  Future<void> _apply(Expense tx, int sign) async {
    final delta = await _sourceDelta(tx);
    await _applyBalance(tx.accountId, sign * delta);
    if (tx.kind == TxKind.transfer && tx.transferAccountId != null) {
      await _applyBalance(tx.transferAccountId!, sign * tx.amount);
    }
  }

  /// What [tx] does to its own account. A repayment's direction depends on
  /// whose loan it settles.
  Future<double> _sourceDelta(Expense tx) async {
    switch (tx.kind) {
      case TxKind.income:
      case TxKind.borrow:
        return tx.amount;
      case TxKind.repayment:
        final loan = tx.loanId == null ? null : await _loan(tx.loanId!);
        return loan?.direction == LoanDirection.borrowed
            ? -tx.amount
            : tx.amount;
      default:
        return -tx.amount;
    }
  }

  Future<void> _applyBalance(int accountId, double delta) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(accountId))).getSingleOrNull();
    if (account == null) return;
    await (_db.update(_db.accounts)..where((a) => a.id.equals(accountId)))
        .write(AccountsCompanion(balance: Value(account.balance + delta)));
  }

  // --- Loans ---------------------------------------------------------------

  Stream<List<Loan>> watchLoans() =>
      (_db.select(_db.loans)..orderBy([
            (t) => OrderingTerm(
              expression: t.settledAt.isNull(),
              mode: OrderingMode.desc,
            ),
            (t) => OrderingTerm(expression: t.dueDate),
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
          .watch();

  /// Every repayment row, for deriving what each loan still owes.
  Stream<List<Expense>> watchRepayments() => (_db.select(
    _db.expenses,
  )..where((t) => t.kind.equals(TxKind.repayment))).watch();

  Future<Loan?> _loan(int id) =>
      (_db.select(_db.loans)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Loan?> loan(int id) => _loan(id);

  Future<double> repaid(int loanId) async {
    final sum = _db.expenses.amount.sum();
    final q = _db.selectOnly(_db.expenses)
      ..addColumns([sum])
      ..where(
        _db.expenses.loanId.equals(loanId) &
            _db.expenses.kind.equals(TxKind.repayment),
      );
    return (await q.getSingle()).read(sum) ?? 0;
  }

  Future<double> outstanding(int loanId) async {
    final l = await _loan(loanId);
    if (l == null) return 0;
    return l.principal - await repaid(loanId);
  }

  /// Opens a loan and books its principal against [accountId].
  Future<int> createLoan({
    required int personId,
    required int direction,
    required double principal,
    required int accountId,
    String? note,
    DateTime? dueDate,
    DateTime? date,
  }) async {
    return _db.transaction(() async {
      final id = await _db
          .into(_db.loans)
          .insert(
            LoansCompanion.insert(
              personId: personId,
              direction: Value(direction),
              principal: principal,
              note: Value(note),
              dueDate: Value(dueDate),
              createdAt: Value(date ?? DateTime.now()),
            ),
          );
      await addTransaction(
        amount: principal,
        accountId: accountId,
        kind: direction == LoanDirection.borrowed ? TxKind.borrow : TxKind.lend,
        personId: personId,
        loanId: id,
        note: note,
        date: date,
      );
      return id;
    });
  }

  Future<void> updateLoan(
    int id, {
    Value<String?> note = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
  }) => (_db.update(_db.loans)..where((t) => t.id.equals(id))).write(
    LoansCompanion(note: note, dueDate: dueDate),
  );

  /// Books a partial or full repayment; the loan settles itself once the
  /// repayments cover the principal.
  Future<int> repay(
    int loanId, {
    required double amount,
    required int accountId,
    String? note,
    DateTime? date,
  }) async {
    final l = await _loan(loanId);
    if (l == null) throw StateError('Loan $loanId does not exist.');
    return addTransaction(
      amount: amount,
      accountId: accountId,
      kind: TxKind.repayment,
      personId: l.personId,
      loanId: loanId,
      note: note,
      date: date,
    );
  }

  Future<void> _refreshSettled(int loanId) async {
    final l = await _loan(loanId);
    if (l == null) return;
    final done = await repaid(loanId) >= l.principal;
    if (done == (l.settledAt != null)) return;
    await (_db.update(_db.loans)..where((t) => t.id.equals(loanId))).write(
      LoansCompanion(settledAt: Value(done ? DateTime.now() : null)),
    );
  }

  /// Removes a loan and every ledger row it produced, giving the money back
  /// to the accounts it moved through.
  Future<void> deleteLoan(int id) async {
    await _db.transaction(() async {
      final rows = await (_db.select(
        _db.expenses,
      )..where((t) => t.loanId.equals(id))).get();
      for (final tx in rows) {
        await _apply(tx, -1);
      }
      await (_db.delete(_db.expenses)..where((t) => t.loanId.equals(id))).go();
      await (_db.delete(_db.loans)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- Budgets -------------------------------------------------------------

  Stream<List<Budget>> watchBudgets(DateTime month) =>
      (_db.select(_db.budgets)
            ..where((t) => t.monthStart.equals(Fmt.startOfMonth(month)))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.categoryId.isNull(),
                mode: OrderingMode.desc,
              ),
              (t) => OrderingTerm(expression: t.id),
            ]))
          .watch();

  Future<List<Budget>> budgets(DateTime month) => (_db.select(
    _db.budgets,
  )..where((t) => t.monthStart.equals(Fmt.startOfMonth(month)))).get();

  /// Creates or replaces the cap for a category (null = overall) in a month.
  Future<int> setBudget({
    required double amount,
    int? categoryId,
    required DateTime month,
  }) async {
    final start = Fmt.startOfMonth(month);
    final existing =
        await (_db.select(_db.budgets)..where(
              (t) =>
                  t.monthStart.equals(start) &
                  (categoryId == null
                      ? t.categoryId.isNull()
                      : t.categoryId.equals(categoryId)),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.budgets)..where((t) => t.id.equals(existing.id)))
          .write(BudgetsCompanion(amount: Value(amount)));
      return existing.id;
    }
    return _db
        .into(_db.budgets)
        .insert(
          BudgetsCompanion.insert(
            amount: amount,
            categoryId: Value(categoryId),
            monthStart: start,
          ),
        );
  }

  Future<void> updateBudget(int id, {required double amount}) =>
      (_db.update(_db.budgets)..where((t) => t.id.equals(id))).write(
        BudgetsCompanion(amount: Value(amount)),
      );

  Future<void> deleteBudget(int id) =>
      (_db.delete(_db.budgets)..where((t) => t.id.equals(id))).go();

  /// The most recent month before [month] that has any budgets, or null.
  Future<DateTime?> latestBudgetMonthBefore(DateTime month) async {
    final start = Fmt.startOfMonth(month);
    final row =
        await (_db.select(_db.budgets)
              ..where((t) => t.monthStart.isSmallerThanValue(start))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.monthStart,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row?.monthStart;
  }

  /// Copies [from]'s budgets into [to], leaving any caps [to] already has.
  Future<int> copyBudgets({
    required DateTime from,
    required DateTime to,
  }) async {
    final source = await budgets(from);
    final existing = await budgets(to);
    final taken = existing.map((b) => b.categoryId).toSet();
    var copied = 0;
    await _db.batch((b) {
      for (final budget in source) {
        if (taken.contains(budget.categoryId)) continue;
        copied++;
        b.insert(
          _db.budgets,
          BudgetsCompanion.insert(
            amount: budget.amount,
            categoryId: Value(budget.categoryId),
            monthStart: Fmt.startOfMonth(to),
          ),
        );
      }
    });
    return copied;
  }

  // --- Recurring bills & subscriptions -------------------------------------

  Stream<List<RecurringExpense>> watchRecurring() =>
      (_db.select(_db.recurringExpenses)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm(expression: t.nextDueDate)]))
          .watch();

  Future<int> createRecurring(RecurringExpensesCompanion bill) =>
      _db.into(_db.recurringExpenses).insert(bill);

  Future<void> deleteRecurring(int id) =>
      (_db.delete(_db.recurringExpenses)..where((t) => t.id.equals(id))).go();

  /// Books a due bill as a real transaction and rolls its due date forward.
  Future<void> payRecurring(RecurringExpense bill) async {
    if (bill.accountId == null) return;
    await addTransaction(
      amount: bill.amount,
      accountId: bill.accountId!,
      categoryId: bill.categoryId,
      note: bill.name,
      date: bill.nextDueDate,
    );
    await (_db.update(
      _db.recurringExpenses,
    )..where((t) => t.id.equals(bill.id))).write(
      RecurringExpensesCompanion(
        nextDueDate: Value(_advance(bill.nextDueDate, bill.period)),
      ),
    );
  }

  static DateTime _advance(DateTime from, String period) => switch (period) {
    'daily' => from.add(const Duration(days: 1)),
    'weekly' => from.add(const Duration(days: 7)),
    'yearly' => DateTime(from.year + 1, from.month, from.day),
    _ => DateTime(from.year, from.month + 1, from.day),
  };

  // --- Reporting -----------------------------------------------------------

  /// Spend per category id for a period, expenses only.
  Future<Map<int?, double>> spendByCategory(DateTime from, DateTime to) async {
    final rows = await between(from, to);
    final result = <int?, double>{};
    for (final r in rows.where((r) => r.kind == TxKind.expense)) {
      result[r.categoryId] = (result[r.categoryId] ?? 0) + r.amount;
    }
    return result;
  }

  Future<({double income, double expense})> totals(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await between(from, to);
    var income = 0.0;
    var expense = 0.0;
    for (final r in rows) {
      if (r.kind == TxKind.income) {
        income += r.amount;
      } else if (r.kind == TxKind.expense) {
        expense += r.amount;
      }
    }
    return (income: income, expense: expense);
  }

  /// Monthly expense totals for the trailing [months] months, oldest first.
  Future<List<({DateTime month, double income, double expense})>> monthlyTrend(
    int months,
  ) async {
    final now = DateTime.now();
    final result = <({DateTime month, double income, double expense})>[];
    for (var i = months - 1; i >= 0; i--) {
      final start = DateTime(now.year, now.month - i, 1);
      final end = DateTime(now.year, now.month - i + 1, 1);
      final t = await totals(start, end);
      result.add((month: start, income: t.income, expense: t.expense));
    }
    return result;
  }

  Future<double> spentThisMonth({int? categoryId}) async {
    final start = Fmt.startOfMonth(DateTime.now());
    final end = DateTime(start.year, start.month + 1, 1);
    final rows = await between(start, end);
    return rows
        .where(
          (r) =>
              r.kind == TxKind.expense &&
              (categoryId == null || r.categoryId == categoryId),
        )
        .fold<double>(0.0, (a, r) => a + r.amount);
  }
}
