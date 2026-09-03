import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/people/people_repository.dart';
import 'package:mysuite/core/utils/formatters.dart';
import 'package:mysuite/presentation/expenses/providers/expenses_provider.dart';
import 'package:mysuite/presentation/expenses/repository/expense_repository.dart';

/// The budgets tab used to show two full bars for a month whose money had all
/// gone somewhere else. These are the rules that stop it doing that.
void main() {
  late AppDatabase db;
  late Directory avatarRoot;
  late ExpenseRepository repo;
  late ProviderContainer container;
  late int cash;
  late int food;
  late int transport;
  late int groceries;

  final month = Fmt.startOfMonth(DateTime.now());

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    avatarRoot = Directory.systemTemp.createTempSync('mysuite-uncapped');
    repo = ExpenseRepository(
      db,
      PeopleRepository(db, AvatarStorage(avatarRoot)),
    );

    cash = (await repo.accounts()).firstWhere((a) => a.name == 'Cash').id;
    final categories = await repo.categories();
    food = categories.firstWhere((c) => c.name == 'Food').id;
    transport = categories.firstWhere((c) => c.name == 'Transport').id;
    groceries = categories.firstWhere((c) => c.name == 'Groceries').id;

    container = ProviderContainer(
      overrides: [expenseRepositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (avatarRoot.existsSync()) avatarRoot.deleteSync(recursive: true);
  });

  Future<void> spend(double amount, {int? on, int kind = TxKind.expense}) =>
      repo.addTransaction(
        amount: amount,
        accountId: cash,
        categoryId: on,
        kind: kind,
        date: month,
      );

  Future<UncappedSpending?> uncapped() =>
      container.read(uncappedSpendingProvider.future);

  test('spending outside the caps is reported, not silently dropped', () async {
    await repo.setBudget(amount: 500, categoryId: food, month: month);
    await repo.setBudget(amount: 300, categoryId: transport, month: month);
    await spend(2400, on: groceries);

    final result = await uncapped();

    expect(result, isNotNull);
    expect(result!.total, 2400);
    expect(result.slices.single.label, 'Groceries');
  });

  test('a capped category is never part of the remainder', () async {
    await repo.setBudget(amount: 500, categoryId: food, month: month);
    await spend(200, on: food);
    await spend(900, on: groceries);

    final result = await uncapped();

    expect(result!.total, 900);
    expect(result.slices.map((s) => s.label), isNot(contains('Food')));
  });

  test(
    'an overall cap already covers the month, so nothing is uncapped',
    () async {
      await repo.setBudget(amount: 10000, categoryId: null, month: month);
      await repo.setBudget(amount: 500, categoryId: food, month: month);
      await spend(2400, on: groceries);

      expect(await uncapped(), isNull);
    },
  );

  test('a month whose spending all landed in caps reports nothing', () async {
    await repo.setBudget(amount: 500, categoryId: food, month: month);
    await spend(200, on: food);

    expect(await uncapped(), isNull);
  });

  test(
    'a month with no caps at all puts every taka in the remainder',
    () async {
      await spend(2400, on: groceries);
      await spend(600, on: food);

      final result = await uncapped();

      expect(result!.total, 3000);
      expect(result.slices, hasLength(2));
    },
  );

  test(
    'shares are ordered biggest first, so the top three are worth capping',
    () async {
      await spend(100, on: food);
      await spend(2400, on: groceries);
      await spend(900, on: transport);

      final result = await uncapped();

      expect(result!.slices.map((s) => s.amount), [2400, 900, 100]);
    },
  );

  test(
    'income and transfers are not spending and stay out of the figure',
    () async {
      await spend(2400, on: groceries);
      await spend(5000, on: food, kind: TxKind.income);

      final result = await uncapped();

      // Only the expense counts; income landing in an uncapped category must not
      // read as money that escaped a budget.
      expect(result!.total, 2400);
      expect(result.slices.single.label, 'Groceries');
    },
  );

  test(
    'an expense with no category is named, and flagged as uncappable',
    () async {
      await spend(600);
      await spend(2400, on: groceries);

      final result = await uncapped();

      expect(result!.total, 3000);
      final loose = result.slices.firstWhere((s) => s.isUncategorised);
      expect(loose.label, 'Uncategorised');
      expect(loose.categoryId, isNull);
      expect(loose.amount, 600);
    },
  );

  test('the breakdown adds up to the headline figure', () async {
    await repo.setBudget(amount: 500, categoryId: food, month: month);
    await spend(2400, on: groceries);
    await spend(900, on: transport);
    await spend(600);
    await spend(50, on: food);

    final result = await uncapped();

    expect(
      result!.slices.fold<double>(0, (sum, s) => sum + s.amount),
      result.total,
    );
  });

  test(
    'a cap set after the fact removes that category from the remainder',
    () async {
      await spend(2400, on: groceries);
      expect((await uncapped())!.total, 2400);

      await repo.setBudget(amount: 3000, categoryId: groceries, month: month);
      // Re-derived from the database rather than waiting on the budgets stream:
      // this is asserting the rule, not Riverpod's propagation timing.
      container.invalidate(budgetsProvider);

      expect(await uncapped(), isNull);
    },
  );
}
