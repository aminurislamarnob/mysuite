import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/ai/ai_action.dart';
import 'package:mysuite/core/ai/ai_command_executor.dart';
import 'package:mysuite/core/ai/ai_drafts.dart';
import 'package:mysuite/core/ai/ai_request_context.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/providers/database_provider.dart';
import 'package:mysuite/core/services/notification_service.dart';
import 'package:mysuite/core/settings/app_settings.dart';
import 'package:mysuite/presentation/expenses/repository/expense_repository.dart';
import 'package:mysuite/presentation/habits/repository/habit_repository.dart';
import 'package:mysuite/presentation/medicine/repository/medicine_repository.dart';
import 'package:mysuite/presentation/notes/repository/note_repository.dart';
import 'package:mysuite/presentation/tasks/repository/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records what would have been scheduled instead of touching the platform
/// plugin, which has no implementation under `flutter test`.
class _RecordingNotifications extends NotificationService {
  _RecordingNotifications(super.ref);

  final tasks = <int>[];
  final notes = <int>[];
  final doses = <int>[];

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
  Future<void> scheduleDose({
    required int doseId,
    required String medicineName,
    required String dosageLabel,
    required String mealHint,
    required DateTime when,
  }) async => doses.add(doseId);
}

final _contextProvider = FutureProvider<AiRequestContext>(
  (ref) => buildAiRequestContext(ref),
);

void main() {
  late AppDatabase db;
  late Directory avatarRoot;
  late ProviderContainer container;
  late _RecordingNotifications notifications;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    avatarRoot = Directory.systemTemp.createTempSync('mysuite-ai');
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
    // Force the recording service to exist before anything schedules.
    container.read(notificationServiceProvider);
    await container
        .read(habitRepositoryProvider)
        .createHabit(
          HabitsCompanion.insert(name: 'Water', unit: const Value('glasses')),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (avatarRoot.existsSync()) avatarRoot.deleteSync(recursive: true);
  });

  Future<AiRequestContext> context() => container.read(_contextProvider.future);
  AiCommandExecutor executor() => container.read(aiCommandExecutorProvider);

  group('resolve', () {
    test('matches the seeded names and falls back with a warning', () async {
      final c = await context();
      final previews = await executor().resolve(const [
        AddExpenseAction(amount: 200, category: 'Food', account: 'bKash'),
        AddExpenseAction(amount: 50, category: 'Crypto', account: 'paytm'),
      ], c);

      final good = previews[0];
      expect(good.clean, isTrue);
      final gd = good.draft as ExpenseDraft;
      expect(gd.categoryName, 'Food');
      expect(gd.accountName, 'bKash');
      expect(
        gd.categoryId,
        c.categories.firstWhere((x) => x.name == 'Food').id,
      );

      final bad = previews[1];
      expect(bad.blocked, isFalse);
      expect(bad.warnings, hasLength(2));
      final bd = bad.draft as ExpenseDraft;
      expect(bd.categoryName, 'Other');
      expect(bd.accountName, 'Cash');
    });

    test('a switched-off module blocks the card', () async {
      final c = await context();
      final off = AiRequestContext(
        now: c.now,
        enabledModules: {AppModule.tasks},
        categories: c.categories,
        accounts: c.accounts,
      );
      final previews = await executor().resolve(const [
        AddExpenseAction(amount: 10),
        AddTaskAction(title: 'Ok'),
      ], off);
      expect(previews[0].blocked, isTrue);
      expect(previews[0].warnings.single, contains('turned off'));
      expect(previews[1].clean, isTrue);
    });

    test('an unknown habit is blocked, a known one keeps its unit', () async {
      final c = await context();
      final previews = await executor().resolve(const [
        LogHabitAction(habit: 'Water', amount: 2),
        LogHabitAction(habit: 'Yoga'),
      ], c);
      final water = previews[0].draft as HabitLogDraft;
      expect(water.unit, 'glasses');
      expect(previews[0].clean, isTrue);
      expect(previews[1].blocked, isTrue);
    });

    test('medicine defaults: 7 days, 3 doses spread across the day', () async {
      final c = await context();
      final previews = await executor().resolve(const [
        AddMedicineAction(name: 'Napa', timesPerDay: 3, days: 5),
        AddMedicineAction(name: 'Seclo'),
      ], c);
      final napa = previews[0].draft as MedicineDraft;
      expect(napa.doseMinutes, [480, 840, 1200]);
      expect(napa.days, 5);
      expect(previews[0].clean, isTrue);
      final seclo = previews[1].draft as MedicineDraft;
      expect(seclo.days, 7);
      expect(previews[1].warnings.single, contains('7 days'));
    });
  });

  group('saveAll', () {
    test(
      'writes rows through the repositories and schedules reminders',
      () async {
        final c = await context();
        // Whole minutes: SQLite stores seconds, so microseconds would not
        // survive the round trip.
        final reminder = DateTime(
          c.now.year,
          c.now.month,
          c.now.day,
          c.now.hour,
          c.now.minute,
        ).add(const Duration(hours: 3));
        final previews = await executor().resolve([
          const AddExpenseAction(
            amount: 200,
            category: 'Food',
            account: 'bKash',
            note: 'Lunch',
          ),
          AddTaskAction(
            title: 'Call the doctor',
            dueDate: reminder,
            hasTime: true,
            reminder: reminder,
            tags: const ['health'],
          ),
          const AddMedicineAction(name: 'Napa', timesPerDay: 3, days: 5),
          AddNoteAction(
            title: 'Wifi',
            body: 'password is hunter2',
            reminder: reminder,
          ),
          const LogHabitAction(habit: 'Water', amount: 2),
        ], c);
        expect(previews.every((p) => p.clean), isTrue);

        final outcome = await executor().saveAll(previews.map((p) => p.draft));
        expect(outcome.failures, isEmpty);
        final saved = outcome.saved;
        expect(saved, hasLength(5));

        // Expense: the ledger and the balance moved together.
        final bkash = (await db.select(db.accounts).get()).firstWhere(
          (a) => a.name == 'bKash',
        );
        expect(bkash.balance, -200);
        final expense = (await db.select(db.expenses).get()).single;
        expect(expense.note, 'Lunch');
        expect(expense.personId, isNotNull);

        // Task: tags attached, reminder scheduled once.
        final task = (await db.select(db.tasks).get()).single;
        expect(task.reminderTime, reminder);
        final tags = await container
            .read(taskRepositoryProvider)
            .tagsForTask(task.id);
        expect(tags.map((t) => t.name), ['health']);
        expect(notifications.tasks, [task.id]);

        // Medicine: the whole course materialised, near-term doses reminded.
        final medicine = (await db.select(db.medicines).get()).single;
        final doses = await container
            .read(medicineRepositoryProvider)
            .dosesFor(medicine.id);
        expect(doses, hasLength(15));
        expect(notifications.doses, isNotEmpty);
        expect(notifications.doses.length, lessThanOrEqualTo(15));

        // Note: a valid delta, searchable, with its reminder.
        final note = (await db.select(db.notes).get()).single;
        final ops = jsonDecode(note.content) as List;
        expect((ops.single as Map)['insert'], 'password is hunter2\n');
        expect(note.plainText, 'password is hunter2');
        expect(note.reminderAt, reminder);
        expect(notifications.notes, [note.id]);

        // Habit: today's log carries the spoken amount.
        final log = (await db.select(db.habitLogs).get()).single;
        expect(log.amount, 2);

        expect(saved.map((s) => s.route), [
          '/expenses',
          '/tasks',
          '/medicine',
          '/note_editor',
          '/habits',
        ]);
      },
    );

    test('one failure does not abort the rest', () async {
      final c = await context();
      final previews = await executor().resolve(const [
        LogHabitAction(habit: 'Water'),
        AddExpenseAction(amount: 75, category: 'Transport'),
      ], c);
      final drafts = [
        // A habit id that does not exist violates the foreign key.
        const HabitLogDraft(habitId: 999, habitName: 'Ghost'),
        ...previews.map((p) => p.draft),
      ];

      final outcome = await executor().saveAll(drafts);
      expect(outcome.results, hasLength(3));
      expect(outcome.results.first, isNull);
      expect(outcome.saved, hasLength(2));
      expect(outcome.failures.single, contains('Ghost'));
      expect(await db.select(db.expenses).get(), hasLength(1));
      expect(await db.select(db.habitLogs).get(), hasLength(1));
    });

    test('the seeded self row is who an expense is for by default', () async {
      final c = await context();
      final previews = await executor().resolve(const [
        AddExpenseAction(amount: 10, person: 'me'),
      ], c);
      expect(previews.single.clean, isTrue);
      await executor().save(previews.single.draft);
      final expense = (await db.select(db.expenses).get()).single;
      final self = (await db.select(db.people).get()).single;
      expect(expense.personId, self.id);
      expect(container.read(expenseRepositoryProvider), isNotNull);
      expect(container.read(noteRepositoryProvider), isNotNull);
    });
  });
}
