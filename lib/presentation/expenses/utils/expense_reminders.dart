import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/people/people_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/settings/app_settings.dart';
import '../repository/expense_repository.dart';

final expenseRemindersProvider = Provider<ExpenseReminders>((ref) {
  return ExpenseReminders(
    repo: ref.watch(expenseRepositoryProvider),
    people: ref.watch(peopleRepositoryProvider),
    notifier: ref.watch(notificationServiceProvider),
    currency: ref.watch(settingsProvider.select((s) => s.currencySymbol)),
  );
});

/// Keeps the due-date notifications for bills and loans in step with the
/// rows they describe. Each reminds once, on the morning it falls due. The
/// row is the source of truth: every write site calls back in here after the
/// database has changed rather than working out the schedule itself, so a
/// bill paid, a loan settled or a repayment undone all land on the same path.
class ExpenseReminders {
  ExpenseReminders({
    required this.repo,
    required this.people,
    required this.notifier,
    required this.currency,
  });

  final ExpenseRepository repo;
  final PeopleRepository people;
  final NotificationService notifier;
  final String currency;

  /// Bills and loans have a date but no time, so they ring at breakfast.
  static const hour = 9;

  static DateTime morningOf(DateTime day) =>
      DateTime(day.year, day.month, day.day, hour);

  Future<void> syncBill(RecurringExpense bill) async {
    // Cancel first: a due date now in the past would otherwise leave the old
    // schedule standing, since past dates are skipped rather than booked.
    await notifier.cancelBillReminder(bill.id);
    if (!bill.isActive) return;
    await notifier.scheduleBillReminder(
      billId: bill.id,
      name: bill.name,
      amount: bill.amount,
      currency: currency,
      when: morningOf(bill.nextDueDate),
    );
  }

  Future<void> cancelBill(int billId) => notifier.cancelBillReminder(billId);

  /// Reads the loan afresh, so it is right whether the caller just opened,
  /// repaid, deleted or un-deleted something against it.
  Future<void> syncLoan(int loanId) async {
    await notifier.cancelLoanReminder(loanId);
    final loan = await repo.loan(loanId);
    final due = loan?.dueDate;
    if (loan == null || due == null || loan.settledAt != null) return;
    final outstanding = await repo.outstanding(loanId);
    if (outstanding <= 0) return;
    final person = (await people.people()).where((p) => p.id == loan.personId);
    await notifier.scheduleLoanReminder(
      loanId: loanId,
      personName: person.firstOrNull?.name ?? 'Someone',
      lent: loan.direction == LoanDirection.lent,
      outstanding: outstanding,
      currency: currency,
      when: morningOf(due),
    );
  }

  Future<void> cancelLoan(int loanId) => notifier.cancelLoanReminder(loanId);

  /// Re-arms every bill and open loan. Run once per launch so rows that
  /// predate reminders, or outlived a cleared schedule, still get theirs.
  Future<void> syncAll() async {
    for (final bill in await repo.recurring()) {
      await syncBill(bill);
    }
    for (final loan in await repo.loans()) {
      await syncLoan(loan.id);
    }
  }
}
