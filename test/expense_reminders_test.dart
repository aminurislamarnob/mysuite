import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/people/people_repository.dart';
import 'package:mysuite/core/providers/database_provider.dart';
import 'package:mysuite/core/services/notification_service.dart';
import 'package:mysuite/core/settings/app_settings.dart';
import 'package:mysuite/presentation/expenses/repository/expense_repository.dart';
import 'package:mysuite/presentation/expenses/utils/expense_reminders.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _Bill = ({int id, String name, double amount, DateTime when});
typedef _Loan = ({
  int id,
  String person,
  bool lent,
  double outstanding,
  DateTime when,
});

/// Keeps what is currently armed, keyed by id, the way the platform would.
class _RecordingNotifications extends NotificationService {
  _RecordingNotifications(super.ref);

  final bills = <int, _Bill>{};
  final loans = <int, _Loan>{};

  @override
  Future<void> scheduleBillReminder({
    required int billId,
    required String name,
    required double amount,
    required String currency,
    required DateTime when,
  }) async =>
      bills[billId] = (id: billId, name: name, amount: amount, when: when);

  @override
  Future<void> cancelBillReminder(int billId) async => bills.remove(billId);

  @override
  Future<void> scheduleLoanReminder({
    required int loanId,
    required String personName,
    required bool lent,
    required double outstanding,
    required String currency,
    required DateTime when,
  }) async => loans[loanId] = (
    id: loanId,
    person: personName,
    lent: lent,
    outstanding: outstanding,
    when: when,
  );

  @override
  Future<void> cancelLoanReminder(int loanId) async => loans.remove(loanId);
}

void main() {
  late AppDatabase db;
  late Directory avatarRoot;
  late ProviderContainer container;
  late _RecordingNotifications notifications;
  late ExpenseRepository repo;
  late PeopleRepository people;
  late ExpenseReminders reminders;
  late int cash;
  late int rahim;

  final nextWeek = DateTime.now().add(const Duration(days: 7));
  final dueDay = DateTime(nextWeek.year, nextWeek.month, nextWeek.day);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    avatarRoot = Directory.systemTemp.createTempSync('mysuite-reminders');
    container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        avatarStorageProvider.overrideWithValue(AvatarStorage(avatarRoot)),
        notificationServiceProvider.overrideWith((ref) {
          return notifications = _RecordingNotifications(ref);
        }),
      ],
    );
    repo = container.read(expenseRepositoryProvider);
    people = container.read(peopleRepositoryProvider);
    reminders = container.read(expenseRemindersProvider);
    cash = (await repo.accounts()).firstWhere((a) => a.name == 'Cash').id;
    rahim = await people.createPerson(name: 'Rahim', type: PersonType.contact);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (avatarRoot.existsSync()) avatarRoot.deleteSync(recursive: true);
  });

  Future<RecurringExpense> addBill({String period = 'monthly'}) =>
      repo.createRecurring(
        RecurringExpensesCompanion.insert(
          name: 'Internet',
          amount: 1200,
          period: Value(period),
          nextDueDate: dueDay,
          accountId: Value(cash),
        ),
      );

  group('bills', () {
    test('a new bill rings at breakfast on its due date', () async {
      final bill = await addBill();
      await reminders.syncBill(bill);

      final armed = notifications.bills[bill.id]!;
      expect(armed.name, 'Internet');
      expect(armed.amount, 1200);
      expect(armed.when, dueDay.add(const Duration(hours: 9)));
    });

    test('paying a bill moves the reminder to the next due date', () async {
      final bill = await addBill();
      await reminders.syncBill(bill);

      final next = await repo.payRecurring(bill);
      await reminders.syncBill(next);

      expect(notifications.bills, hasLength(1));
      expect(
        notifications.bills[bill.id]!.when,
        DateTime(dueDay.year, dueDay.month + 1, dueDay.day, 9),
      );
    });

    test('cancelling drops the reminder', () async {
      final bill = await addBill();
      await reminders.syncBill(bill);
      await reminders.cancelBill(bill.id);
      expect(notifications.bills, isEmpty);
    });
  });

  group('loans', () {
    Future<int> lend({DateTime? due, int direction = LoanDirection.lent}) =>
        repo.createLoan(
          personId: rahim,
          direction: direction,
          principal: 500,
          accountId: cash,
          dueDate: due,
        );

    test('a loan without a due date schedules nothing', () async {
      final id = await lend();
      await reminders.syncLoan(id);
      expect(notifications.loans, isEmpty);
    });

    test('a due loan is worded from the lender\'s side', () async {
      final id = await lend(due: dueDay);
      await reminders.syncLoan(id);

      final armed = notifications.loans[id]!;
      expect(armed.person, 'Rahim');
      expect(armed.lent, isTrue);
      expect(armed.outstanding, 500);
      expect(armed.when, dueDay.add(const Duration(hours: 9)));
    });

    test('a borrowed loan is worded from the borrower\'s side', () async {
      final id = await lend(due: dueDay, direction: LoanDirection.borrowed);
      await reminders.syncLoan(id);
      expect(notifications.loans[id]!.lent, isFalse);
    });

    test('a partial repayment lowers what the reminder says', () async {
      final id = await lend(due: dueDay);
      await reminders.syncLoan(id);
      await repo.repay(id, amount: 200, accountId: cash);
      await reminders.syncLoan(id);
      expect(notifications.loans[id]!.outstanding, 300);
    });

    test(
      'settling in full cancels, and undoing the repayment re-arms',
      () async {
        final id = await lend(due: dueDay);
        await reminders.syncLoan(id);

        final repayment = await repo.repay(id, amount: 500, accountId: cash);
        await reminders.syncLoan(id);
        expect(notifications.loans, isEmpty);

        final deleted = await repo.deleteTransaction(repayment);
        await reminders.syncLoan(deleted!.loanId!);
        expect(notifications.loans[id]!.outstanding, 500);
      },
    );

    test('deleting the loan drops the reminder', () async {
      final id = await lend(due: dueDay);
      await reminders.syncLoan(id);
      await repo.deleteLoan(id);
      await reminders.syncLoan(id);
      expect(notifications.loans, isEmpty);
    });
  });

  test('syncAll arms every bill and every open dated loan', () async {
    await addBill();
    await addBill(period: 'weekly');
    final open = await repo.createLoan(
      personId: rahim,
      direction: LoanDirection.lent,
      principal: 100,
      accountId: cash,
      dueDate: dueDay,
    );
    final undated = await repo.createLoan(
      personId: rahim,
      direction: LoanDirection.lent,
      principal: 100,
      accountId: cash,
    );

    await reminders.syncAll();

    expect(notifications.bills, hasLength(2));
    expect(notifications.loans.keys, [open]);
    expect(notifications.loans.containsKey(undated), isFalse);
  });
}
