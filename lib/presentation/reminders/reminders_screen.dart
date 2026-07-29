import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../expenses/providers/expenses_provider.dart';
import '../habits/repository/habit_repository.dart';
import '../medicine/repository/medicine_repository.dart';
import '../notes/repository/note_repository.dart';
import '../tasks/repository/task_repository.dart';

/// One row in the unified reminders inbox.
class ReminderItem {
  final String title;
  final String subtitle;
  final DateTime at;
  final IconData icon;
  final Color color;
  final String route;

  const ReminderItem({
    required this.title,
    required this.subtitle,
    required this.at,
    required this.icon,
    required this.color,
    required this.route,
  });
}

/// Collects every scheduled reminder across modules into one chronological
/// list — the spec's "cross-module reminders inbox".
final remindersProvider = FutureProvider<List<ReminderItem>>((ref) async {
  final settings = ref.watch(settingsProvider);
  final items = <ReminderItem>[];

  if (settings.isEnabled(AppModule.medicine)) {
    final doses =
        await ref.watch(medicineRepositoryProvider).upcomingDoses(limit: 20);
    final meds = {
      for (final m in await ref.watch(medicineRepositoryProvider).medicines())
        m.id: m
    };
    for (final d in doses) {
      final med = meds[d.medicineId];
      if (med == null) continue;
      items.add(ReminderItem(
        title: med.name,
        subtitle: '${med.dosage.toStringAsFixed(0)} ${med.dosageUnit}',
        at: d.scheduledTime,
        icon: Icons.medication_outlined,
        color: AppColors.medicineAccent,
        route: '/medicine',
      ));
    }
  }

  if (settings.isEnabled(AppModule.tasks)) {
    final tasks =
        await ref.watch(taskRepositoryProvider).tasksWithReminders();
    for (final t in tasks) {
      items.add(ReminderItem(
        title: t.title,
        subtitle: 'Task reminder',
        at: t.reminderTime!,
        icon: Icons.check_circle_outline,
        color: AppColors.taskAccent,
        route: '/tasks',
      ));
    }
  }

  if (settings.isEnabled(AppModule.notes)) {
    final notes =
        await ref.watch(noteRepositoryProvider).notesWithReminders();
    for (final n in notes) {
      items.add(ReminderItem(
        title: n.title,
        subtitle: 'Note reminder',
        at: n.reminderAt!,
        icon: Icons.description_outlined,
        color: AppColors.noteAccent,
        route: '/notes',
      ));
    }
  }

  if (settings.isEnabled(AppModule.habits)) {
    final habits =
        await ref.watch(habitRepositoryProvider).habitsWithReminders();
    final today = Fmt.dateOnly(DateTime.now());
    for (final h in habits) {
      var when = today.add(Duration(minutes: h.reminderMinutes!));
      if (when.isBefore(DateTime.now())) {
        when = when.add(const Duration(days: 1));
      }
      items.add(ReminderItem(
        title: h.name,
        subtitle: 'Daily habit nudge',
        at: when,
        icon: Icons.local_cafe_outlined,
        color: Color(h.color),
        route: '/habits',
      ));
    }
  }

  if (settings.isEnabled(AppModule.expenses)) {
    final bills = await ref.watch(recurringProvider.future);
    for (final b in bills) {
      items.add(ReminderItem(
        title: b.name,
        subtitle:
            '${settings.currencySymbol}${b.amount.toStringAsFixed(0)} due',
        at: b.nextDueDate,
        icon: Icons.receipt_long_outlined,
        color: AppColors.expenseAccent,
        route: '/expenses',
      ));
    }
  }

  items.sort((a, b) => a.at.compareTo(b.at));
  return items;
});

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: reminders.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'Nothing scheduled',
              message:
                  'Dose times, task reminders, habit nudges and bill due dates '
                  'all show up here.',
            );
          }

          // Group by day so the inbox reads as an agenda.
          final groups = <DateTime, List<ReminderItem>>{};
          for (final r in items) {
            groups.putIfAbsent(Fmt.dateOnly(r.at), () => []).add(r);
          }
          final days = groups.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            itemCount: days.length,
            itemBuilder: (_, i) {
              final day = days[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(Fmt.relativeDay(day),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  ...groups[day]!.map((r) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: r.color.withValues(alpha: 0.13),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(r.icon, size: 18, color: r.color),
                          ),
                          title: Text(r.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(r.subtitle,
                              style: const TextStyle(fontSize: 11)),
                          trailing: Text(Fmt.time(r.at),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12)),
                          onTap: () => context.push(r.route),
                        ),
                      )),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            EmptyState(icon: Icons.error_outline, title: 'Error', message: '$e'),
      ),
    );
  }
}
