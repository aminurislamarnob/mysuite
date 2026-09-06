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
import 'package:mysuite/core/services/reminder_sync.dart';
import 'package:mysuite/core/settings/app_settings.dart';
import 'package:mysuite/presentation/expenses/repository/expense_repository.dart';
import 'package:mysuite/presentation/habits/repository/habit_repository.dart';
import 'package:mysuite/presentation/medicine/repository/medicine_repository.dart';
import 'package:mysuite/presentation/medicine/utils/schedule_generator.dart';
import 'package:mysuite/presentation/notes/repository/note_repository.dart';
import 'package:mysuite/presentation/tasks/repository/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records ids per kind instead of touching the platform plugin.
class _RecordingNotifications extends NotificationService {
  _RecordingNotifications(super.ref);

  final tasks = <int>[];
  final notes = <int>[];
  final habits = <int>[];
  final doses = <int>[];
  final bills = <int>[];
  final loans = <int>[];
  final dosageLabels = <String>{};

  @override
  Future<void> scheduleTaskReminder({
    required int taskId,
    required String title,
    required DateTime when,
  }) async => tasks.add(taskId);

  @override
  Future<void> scheduleNoteReminder({
    required int noteId,
    required String title,
    required DateTime when,
  }) async => notes.add(noteId);

  @override
  Future<void> scheduleHabitNudge({
    required int habitId,
    required String habitName,
    required int minutesFromMidnight,
  }) async => habits.add(habitId);

  @override
  Future<void> scheduleDose({
    required int doseId,
    required String medicineName,
    required String dosageLabel,
    required String mealHint,
    required DateTime when,
  }) async {
    doses.add(doseId);
    dosageLabels.add(dosageLabel);
  }

  @override
  Future<void> scheduleBillReminder({
    required int billId,
    required String name,
    required double amount,
    required String currency,
    required DateTime when,
  }) async => bills.add(billId);

  @override
  Future<void> cancelBillReminder(int billId) async {}

  @override
  Future<void> scheduleLoanReminder({
    required int loanId,
    required String personName,
    required bool lent,
    required double outstanding,
    required String currency,
    required DateTime when,
  }) async => loans.add(loanId);

  @override
  Future<void> cancelLoanReminder(int loanId) async {}
}

void main() {
  late AppDatabase db;
  late Directory avatarRoot;
  late ProviderContainer container;
  late _RecordingNotifications notifications;

  final tomorrow = DateTime.now().add(const Duration(days: 1));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    avatarRoot = Directory.systemTemp.createTempSync('mysuite-sync');
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
    container.read(notificationServiceProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (avatarRoot.existsSync()) avatarRoot.deleteSync(recursive: true);
  });

  Future<int> task({DateTime? reminder, bool done = false}) async {
    final repo = container.read(taskRepositoryProvider);
    final id = await repo.createTask(title: 'Call', reminderTime: reminder);
    if (done) await repo.setCompleted(id, true);
    return id;
  }

  Future<int> medicine() async {
    final repo = container.read(medicineRepositoryProvider);
    final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    return repo.createMedicineWithSchedule(
      medicine: MedicinesCompanion(
        name: const Value('Napa'),
        dosage: const Value(1.5),
        dosageUnit: const Value('tablet'),
        startDate: Value(start),
        endDate: Value(start),
      ),
      spec: ScheduleSpec(start: start, end: start, doseMinutes: const [480]),
    );
  }

  test('every module with something due gets re-armed', () async {
    final due = await task(reminder: tomorrow);
    await task();
    await task(reminder: tomorrow, done: true);

    final notes = container.read(noteRepositoryProvider);
    final noted = await notes.createNote(
      title: 'Idea',
      contentJson: NoteRepository.emptyDelta,
    );
    await notes.updateNote(noted, reminderAt: tomorrow);
    await notes.createNote(
      title: 'Quiet',
      contentJson: NoteRepository.emptyDelta,
    );

    final habit = await container
        .read(habitRepositoryProvider)
        .createHabit(
          const HabitsCompanion(
            name: Value('Water'),
            reminderMinutes: Value(540),
          ),
        );

    final med = await medicine();

    final expenses = container.read(expenseRepositoryProvider);
    final cash = (await expenses.accounts()).first.id;
    final bill = await expenses.createRecurring(
      RecurringExpensesCompanion.insert(
        name: 'Rent',
        amount: 100,
        nextDueDate: tomorrow,
        accountId: Value(cash),
      ),
    );
    final rahim = await container
        .read(peopleRepositoryProvider)
        .createPerson(name: 'Rahim', type: PersonType.contact);
    final loan = await expenses.createLoan(
      personId: rahim,
      direction: LoanDirection.lent,
      principal: 50,
      accountId: cash,
      dueDate: tomorrow,
    );

    await container.read(reminderSyncProvider).syncAll();

    expect(notifications.tasks, [due]);
    expect(notifications.notes, [noted]);
    expect(notifications.habits, [habit]);
    expect(notifications.doses, hasLength(1));
    expect(notifications.dosageLabels, {'1.5 tablet'});
    expect(notifications.bills, [bill.id]);
    expect(notifications.loans, [loan]);
    expect(med, isPositive);
  });

  test('a switched-off module stays quiet', () async {
    await task(reminder: tomorrow);
    await medicine();
    container
        .read(settingsProvider.notifier)
        .toggleModule(AppModule.tasks, false);

    await container.read(reminderSyncProvider).syncAll();

    expect(notifications.tasks, isEmpty);
    expect(notifications.doses, hasLength(1));
  });
}
