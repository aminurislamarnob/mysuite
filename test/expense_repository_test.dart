import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/people_repository.dart';
import 'package:mysuite/presentation/expenses/repository/expense_repository.dart';

void main() {
  late AppDatabase db;
  late PeopleRepository people;
  late ExpenseRepository repo;
  late int cash;
  late int bank;
  late int food;
  late int other;

  Future<double> balance(int id) async => (await (db.select(
    db.accounts,
  )..where((a) => a.id.equals(id))).getSingle()).balance;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    people = PeopleRepository(db);
    repo = ExpenseRepository(db, people);

    final accounts = await repo.accounts();
    cash = accounts.firstWhere((a) => a.name == 'Cash').id;
    bank = accounts.firstWhere((a) => a.name == 'Bank').id;
    final categories = await repo.categories();
    food = categories.firstWhere((c) => c.name == 'Food').id;
    other = categories.firstWhere((c) => c.name == 'Other').id;
  });

  tearDown(() async => db.close());

  group('transactions', () {
    test('a transaction defaults to Self', () async {
      final id = await repo.addTransaction(amount: 100, accountId: cash);
      final tx = await repo.transaction(id);
      expect(tx!.personId, await people.selfId());
    });

    test('editing the amount moves only the difference', () async {
      final id = await repo.addTransaction(amount: 100, accountId: cash);
      expect(await balance(cash), -100);

      await repo.updateTransaction(id, amount: 250);
      expect(await balance(cash), -250);
    });

    test('editing the account gives the old one its money back', () async {
      final id = await repo.addTransaction(amount: 100, accountId: cash);

      await repo.updateTransaction(id, accountId: bank);
      expect(await balance(cash), 0);
      expect(await balance(bank), -100);
    });

    test('flipping expense to income reverses the sign', () async {
      final id = await repo.addTransaction(amount: 100, accountId: cash);

      await repo.updateTransaction(id, kind: TxKind.income);
      expect(await balance(cash), 100);
    });

    test('editing a transfer re-routes both ends', () async {
      final id = await repo.addTransaction(
        amount: 500,
        accountId: cash,
        kind: TxKind.transfer,
        transferAccountId: bank,
      );
      expect(await balance(cash), -500);
      expect(await balance(bank), 500);

      await repo.updateTransaction(
        id,
        accountId: bank,
        transferAccountId: Value(cash),
      );
      expect(await balance(cash), 500);
      expect(await balance(bank), -500);
    });

    test('delete then restore leaves the balance where it started', () async {
      final id = await repo.addTransaction(
        amount: 100,
        accountId: cash,
        receiptPath: '/receipts/1.jpg',
      );

      final deleted = await repo.deleteTransaction(id);
      expect(await balance(cash), 0);
      expect(await repo.transaction(id), isNull);

      await repo.restoreTransaction(deleted!);
      expect(await balance(cash), -100);
      final restored = await repo.transaction(id);
      expect(restored!.id, id);
      expect(restored.receiptPath, '/receipts/1.jpg');
    });
  });

  group('loans', () {
    late int friend;

    setUp(() async {
      friend = await people.createPerson(
        name: 'Rahim',
        type: PersonType.contact,
      );
    });

    test('lending leaves the account but is not spending', () async {
      await repo.createLoan(
        personId: friend,
        direction: LoanDirection.lent,
        principal: 5000,
        accountId: cash,
      );
      expect(await balance(cash), -5000);

      final now = DateTime.now();
      final t = await repo.totals(
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 1),
      );
      expect(t.expense, 0);
      expect(t.income, 0);
    });

    test('partial repayments reduce what is owed and settle at zero', () async {
      final id = await repo.createLoan(
        personId: friend,
        direction: LoanDirection.lent,
        principal: 5000,
        accountId: cash,
      );

      await repo.repay(id, amount: 2000, accountId: cash);
      expect(await repo.outstanding(id), 3000);
      expect(await balance(cash), -3000);
      expect((await repo.loan(id))!.settledAt, isNull);

      await repo.repay(id, amount: 3000, accountId: bank);
      expect(await repo.outstanding(id), 0);
      expect(await balance(bank), 3000);
      expect((await repo.loan(id))!.settledAt, isNotNull);
    });

    test('repaying money I borrowed leaves my account', () async {
      final id = await repo.createLoan(
        personId: friend,
        direction: LoanDirection.borrowed,
        principal: 1000,
        accountId: cash,
      );
      expect(await balance(cash), 1000);

      await repo.repay(id, amount: 400, accountId: cash);
      expect(await balance(cash), 600);
      expect(await repo.outstanding(id), 600);
    });

    test('undoing a repayment reopens a settled loan', () async {
      final id = await repo.createLoan(
        personId: friend,
        direction: LoanDirection.lent,
        principal: 1000,
        accountId: cash,
      );
      final repayment = await repo.repay(id, amount: 1000, accountId: cash);
      expect((await repo.loan(id))!.settledAt, isNotNull);

      await repo.deleteTransaction(repayment);
      expect((await repo.loan(id))!.settledAt, isNull);
      expect(await balance(cash), -1000);
    });

    test('deleting a loan gives every account its money back', () async {
      final id = await repo.createLoan(
        personId: friend,
        direction: LoanDirection.lent,
        principal: 5000,
        accountId: cash,
      );
      await repo.repay(id, amount: 2000, accountId: bank);

      await repo.deleteLoan(id);
      expect(await balance(cash), 0);
      expect(await balance(bank), 0);
      expect(await repo.loan(id), isNull);
      expect(await (db.select(db.expenses)).get(), isEmpty);
    });

    test('deleting the principal row deletes the whole loan', () async {
      final id = await repo.createLoan(
        personId: friend,
        direction: LoanDirection.lent,
        principal: 5000,
        accountId: cash,
      );
      final principal = (await (db.select(
        db.expenses,
      )..where((t) => t.loanId.equals(id))).getSingle()).id;

      await repo.deleteTransaction(principal);
      expect(await repo.loan(id), isNull);
      expect(await balance(cash), 0);
    });
  });

  group('categories', () {
    test('deleting with history moves rows, bills and drops budgets', () async {
      final month = DateTime(2026, 9, 1);
      await repo.addTransaction(amount: 10, accountId: cash, categoryId: food);
      await repo.createRecurring(
        RecurringExpensesCompanion.insert(
          name: 'Tiffin',
          amount: 50,
          categoryId: Value(food),
          nextDueDate: month,
        ),
      );
      await repo.setBudget(amount: 500, categoryId: food, month: month);

      await repo.deleteCategory(food, reassignTo: other);

      final tx = await (db.select(db.expenses)).getSingle();
      expect(tx.categoryId, other);
      final bill = await (db.select(db.recurringExpenses)).getSingle();
      expect(bill.categoryId, other);
      expect(await repo.budgets(month), isEmpty);
      expect((await repo.categories()).any((c) => c.id == food), isFalse);
    });

    test('deleting with history and no destination is refused', () async {
      await repo.addTransaction(amount: 10, accountId: cash, categoryId: food);
      expect(() => repo.deleteCategory(food), throwsStateError);
      expect((await repo.categories()).any((c) => c.id == food), isTrue);
    });

    test('an unused category deletes without a destination', () async {
      await repo.deleteCategory(food);
      expect((await repo.categories()).any((c) => c.id == food), isFalse);
    });

    test('new categories go to the end', () async {
      final id = await repo.createCategory('Gym', 'gym', 0xFF000000);
      expect((await repo.categories()).last.id, id);
    });
  });

  group('budgets', () {
    final aug = DateTime(2026, 8, 1);
    final sep = DateTime(2026, 9, 1);

    test('a cap belongs to one month', () async {
      await repo.setBudget(amount: 500, categoryId: food, month: aug);
      expect(await repo.budgets(sep), isEmpty);
      expect((await repo.budgets(aug)).single.amount, 500);
    });

    test('setting the same cap twice in a month replaces it', () async {
      await repo.setBudget(amount: 500, categoryId: food, month: sep);
      await repo.setBudget(amount: 800, categoryId: food, month: sep);
      await repo.setBudget(amount: 9000, month: sep);
      await repo.setBudget(amount: 9500, month: sep);

      final rows = await repo.budgets(sep);
      expect(rows.length, 2);
      expect(rows.firstWhere((b) => b.categoryId == food).amount, 800);
      expect(rows.firstWhere((b) => b.categoryId == null).amount, 9500);
    });

    test('copying fills only the gaps in the target month', () async {
      await repo.setBudget(amount: 500, categoryId: food, month: aug);
      await repo.setBudget(amount: 9000, month: aug);
      await repo.setBudget(amount: 600, categoryId: food, month: sep);

      expect(await repo.latestBudgetMonthBefore(sep), aug);
      final copied = await repo.copyBudgets(from: aug, to: sep);

      expect(copied, 1);
      final rows = await repo.budgets(sep);
      expect(rows.firstWhere((b) => b.categoryId == food).amount, 600);
      expect(rows.firstWhere((b) => b.categoryId == null).amount, 9000);
    });
  });

  group('people', () {
    test('Self cannot be deleted', () async {
      final self = await people.selfId();
      expect(() => people.deletePerson(self), throwsStateError);
    });

    test('deleting a person hands their history to Self', () async {
      final wife = await people.createPerson(name: 'Wife');
      await repo.addTransaction(amount: 10, accountId: cash, personId: wife);

      await people.deletePerson(wife);

      final tx = await (db.select(db.expenses)).getSingle();
      expect(tx.personId, await people.selfId());
    });
  });
}
