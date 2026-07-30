import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(databaseProvider));
});

/// Transaction kinds, mirroring `Expenses.kind`.
class TxKind {
  static const expense = 0;
  static const income = 1;
  static const transfer = 2;
}

class ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepository(this._db);

  // --- Accounts ------------------------------------------------------------

  Stream<List<Account>> watchAccounts() => (_db.select(
    _db.accounts,
  )..where((t) => t.isArchived.equals(false))).watch();

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

  Future<void> deleteAccount(int id) =>
      (_db.delete(_db.accounts)..where((t) => t.id.equals(id))).go();

  // --- Categories ----------------------------------------------------------

  Stream<List<ExpenseCategory>> watchCategories({bool? income}) {
    final q = _db.select(_db.expenseCategories);
    if (income != null) q.where((t) => t.isIncome.equals(income));
    return q.watch();
  }

  Future<List<ExpenseCategory>> categories() =>
      _db.select(_db.expenseCategories).get();

  Future<int> createCategory(
    String name,
    String icon,
    int color, {
    bool isIncome = false,
  }) => _db
      .into(_db.expenseCategories)
      .insert(
        ExpenseCategoriesCompanion.insert(
          name: name,
          icon: Value(icon),
          color: Value(color),
          isIncome: Value(isIncome),
        ),
      );

  Future<void> deleteCategory(int id) =>
      (_db.delete(_db.expenseCategories)..where((t) => t.id.equals(id))).go();

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

  /// Records a transaction and moves the money, in one transaction so a
  /// failure can never leave a balance out of step with its ledger.
  Future<int> addTransaction({
    required double amount,
    required int accountId,
    int? categoryId,
    int kind = TxKind.expense,
    int? transferAccountId,
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
              note: Value(note),
              receiptPath: Value(receiptPath),
              date: Value(date ?? DateTime.now()),
            ),
          );

      await _applyBalance(accountId, kind == TxKind.income ? amount : -amount);
      if (kind == TxKind.transfer && transferAccountId != null) {
        await _applyBalance(transferAccountId, amount);
      }
      return id;
    });
  }

  Future<void> _applyBalance(int accountId, double delta) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(accountId))).getSingleOrNull();
    if (account == null) return;
    await (_db.update(_db.accounts)..where((a) => a.id.equals(accountId)))
        .write(AccountsCompanion(balance: Value(account.balance + delta)));
  }

  /// Deletes a transaction and reverses its effect on the account balances.
  Future<void> deleteTransaction(int id) async {
    await _db.transaction(() async {
      final tx = await (_db.select(
        _db.expenses,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (tx == null) return;

      await _applyBalance(
        tx.accountId,
        tx.kind == TxKind.income ? -tx.amount : tx.amount,
      );
      if (tx.kind == TxKind.transfer && tx.transferAccountId != null) {
        await _applyBalance(tx.transferAccountId!, -tx.amount);
      }
      await (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- Budgets -------------------------------------------------------------

  Stream<List<Budget>> watchBudgets() => _db.select(_db.budgets).watch();

  Future<int> setBudget({
    required double amount,
    int? categoryId,
    String period = 'monthly',
  }) async {
    final existing =
        await (_db.select(_db.budgets)..where(
              (t) => categoryId == null
                  ? t.categoryId.isNull()
                  : t.categoryId.equals(categoryId),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await (_db.update(
        _db.budgets,
      )..where((t) => t.id.equals(existing.id))).write(
        BudgetsCompanion(amount: Value(amount), period: Value(period)),
      );
      return existing.id;
    }
    return _db
        .into(_db.budgets)
        .insert(
          BudgetsCompanion.insert(
            amount: amount,
            categoryId: Value(categoryId),
            period: Value(period),
          ),
        );
  }

  Future<void> deleteBudget(int id) =>
      (_db.delete(_db.budgets)..where((t) => t.id.equals(id))).go();

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
