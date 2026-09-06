import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/expenses/utils/expense_reminders.dart';
import '../../presentation/habits/repository/habit_repository.dart';
import '../../presentation/medicine/providers/medicine_provider.dart';
import '../../presentation/medicine/repository/medicine_repository.dart';
import '../../presentation/medicine/utils/dose_reminders.dart';
import '../../presentation/medicine/utils/schedule_generator.dart';
import '../../presentation/notes/repository/note_repository.dart';
import '../../presentation/tasks/repository/task_repository.dart';
import '../settings/app_settings.dart';
import 'notification_service.dart';

final reminderSyncProvider = Provider<ReminderSync>((ref) {
  return ReminderSync(
    notifier: ref.watch(notificationServiceProvider),
    tasks: ref.watch(taskRepositoryProvider),
    notes: ref.watch(noteRepositoryProvider),
    habits: ref.watch(habitRepositoryProvider),
    medicine: ref.watch(medicineRepositoryProvider),
    expenses: ref.watch(expenseRemindersProvider),
    enabled: ref.watch(settingsProvider.select((s) => s.enabledModules)),
  );
});

/// Re-arms every reminder the database still calls for.
///
/// Each editor schedules as it saves, but that only covers rows written on
/// this device since the feature existed. Rows that arrived some other way, or
/// whose schedule was cleared, would stay silent forever. Running this once
/// per launch makes the database the source of truth: whatever it says is due
/// gets a notification, and modules the user has switched off stay quiet.
///
/// Past dates are skipped by the scheduler itself, and doses keep their
/// two-week window, so this does not swamp the platform's pending cap.
class ReminderSync {
  ReminderSync({
    required this.notifier,
    required this.tasks,
    required this.notes,
    required this.habits,
    required this.medicine,
    required this.expenses,
    required this.enabled,
  });

  final NotificationService notifier;
  final TaskRepository tasks;
  final NoteRepository notes;
  final HabitRepository habits;
  final MedicineRepository medicine;
  final ExpenseReminders expenses;
  final Set<AppModule> enabled;

  Future<void> syncAll() async {
    if (enabled.contains(AppModule.tasks)) await _guard('tasks', syncTasks);
    if (enabled.contains(AppModule.notes)) await _guard('notes', syncNotes);
    if (enabled.contains(AppModule.habits)) await _guard('habits', syncHabits);
    if (enabled.contains(AppModule.medicine)) {
      await _guard('medicine', syncMedicine);
    }
    if (enabled.contains(AppModule.expenses)) {
      await _guard('expenses', expenses.syncAll);
    }
  }

  Future<void> syncTasks() async {
    for (final t in await tasks.tasksWithReminders()) {
      await notifier.scheduleTaskReminder(
        taskId: t.id,
        title: t.title,
        when: t.reminderTime!,
      );
    }
  }

  Future<void> syncNotes() async {
    for (final n in await notes.notesWithReminders()) {
      await notifier.scheduleNoteReminder(
        noteId: n.id,
        title: n.title,
        when: n.reminderAt!,
      );
    }
  }

  Future<void> syncHabits() async {
    for (final h in await habits.habitsWithReminders()) {
      await notifier.scheduleHabitNudge(
        habitId: h.id,
        habitName: h.name,
        minutesFromMidnight: h.reminderMinutes!,
      );
    }
  }

  Future<void> syncMedicine() async {
    for (final m in await medicine.medicines()) {
      if (!m.isActive) continue;
      await scheduleDoseReminders(
        repo: medicine,
        notifier: notifier,
        medicineId: m.id,
        name: m.name,
        dosageLabel: '${DoseView.trimAmount(m.dosage)} ${m.dosageUnit}',
        mealHint: MealRelationX.fromToken(m.mealRelation).label,
      );
    }
  }

  /// One module's scheduling failing, usually a revoked permission, must not
  /// stop the others from being re-armed.
  Future<void> _guard(String module, Future<void> Function() run) async {
    try {
      await run();
    } on Exception catch (e) {
      debugPrint('Could not re-arm $module reminders: $e');
    }
  }
}
