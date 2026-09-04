import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../expenses/providers/expenses_provider.dart';
import '../habits/repository/habit_repository.dart';
import '../medicine/repository/medicine_repository.dart';
import '../modules/modules_screen.dart';
import '../notes/repository/note_repository.dart';
import '../tasks/repository/task_repository.dart';

/// One row in the unified reminders inbox.
class ReminderItem {
  final String title;
  final String subtitle;
  final DateTime at;
  final HugeIconData icon;
  final String route;

  /// Which module this reminder came from. The accent is resolved from the
  /// active palette at render time — this provider has no context, and pinning
  /// a colour here would freeze it to whichever palette was live at build.
  final AppModule module;

  /// A colour of the item's own, for the one case that has one: a habit
  /// carries a user-picked colour that outranks the module accent.
  final Color? colorOverride;

  const ReminderItem({
    required this.title,
    required this.subtitle,
    required this.at,
    required this.icon,
    required this.module,
    required this.route,
    this.colorOverride,
  });

  /// The accent to draw this reminder with.
  Color accent(BrandColors brand) =>
      colorOverride ?? ModulesScreen.accentFor(brand, module);
}

/// Collects every scheduled reminder across modules into one chronological
/// list — the spec's "cross-module reminders inbox".
final remindersProvider = FutureProvider<List<ReminderItem>>((ref) async {
  final settings = ref.watch(settingsProvider);
  final items = <ReminderItem>[];

  if (settings.isEnabled(AppModule.medicine)) {
    final doses = await ref
        .watch(medicineRepositoryProvider)
        .upcomingDoses(limit: 20);
    final meds = {
      for (final m in await ref.watch(medicineRepositoryProvider).medicines())
        m.id: m,
    };
    for (final d in doses) {
      final med = meds[d.medicineId];
      if (med == null) continue;
      items.add(
        ReminderItem(
          title: med.name,
          subtitle: '${med.dosage.toStringAsFixed(0)} ${med.dosageUnit}',
          at: d.scheduledTime,
          icon: AppIcons.medicine,
          module: AppModule.medicine,
          route: '/medicine',
        ),
      );
    }
  }

  if (settings.isEnabled(AppModule.tasks)) {
    final tasks = await ref.watch(taskRepositoryProvider).tasksWithReminders();
    for (final t in tasks) {
      items.add(
        ReminderItem(
          title: t.title,
          subtitle: 'Task reminder',
          at: t.reminderTime!,
          icon: AppIcons.checkCircle,
          module: AppModule.tasks,
          route: '/tasks',
        ),
      );
    }
  }

  if (settings.isEnabled(AppModule.notes)) {
    final notes = await ref.watch(noteRepositoryProvider).notesWithReminders();
    for (final n in notes) {
      items.add(
        ReminderItem(
          title: n.title,
          subtitle: 'Note reminder',
          at: n.reminderAt!,
          icon: AppIcons.notes,
          module: AppModule.notes,
          route: '/notes',
        ),
      );
    }
  }

  if (settings.isEnabled(AppModule.habits)) {
    final habits = await ref
        .watch(habitRepositoryProvider)
        .habitsWithReminders();
    final today = Fmt.dateOnly(DateTime.now());
    for (final h in habits) {
      var when = today.add(Duration(minutes: h.reminderMinutes!));
      if (when.isBefore(DateTime.now())) {
        when = when.add(const Duration(days: 1));
      }
      items.add(
        ReminderItem(
          title: h.name,
          subtitle: 'Daily habit nudge',
          at: when,
          icon: AppIcons.habits,
          module: AppModule.habits,
          colorOverride: Color(h.color),
          route: '/habits',
        ),
      );
    }
  }

  if (settings.isEnabled(AppModule.expenses)) {
    final loans = await ref.watch(loanRowsProvider.future);
    for (final l in loans) {
      final due = l.loan.dueDate;
      if (l.isSettled || due == null) continue;
      items.add(
        ReminderItem(
          title: l.person == null
              ? (l.isLent ? 'Loan due' : 'Repayment due')
              : l.isLent
              ? '${l.person!.name} owes you'
              : 'You owe ${l.person!.name}',
          subtitle:
              '${settings.currencySymbol}'
              '${l.outstanding.toStringAsFixed(0)} outstanding',
          at: due,
          icon: AppIcons.transfer,
          module: AppModule.expenses,
          route: '/expenses',
        ),
      );
    }

    final bills = await ref.watch(recurringProvider.future);
    for (final b in bills) {
      items.add(
        ReminderItem(
          title: b.name,
          subtitle:
              '${settings.currencySymbol}${b.amount.toStringAsFixed(0)} due',
          at: b.nextDueDate,
          icon: AppIcons.bills,
          module: AppModule.expenses,
          route: '/expenses',
        ),
      );
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

    return BrandScaffold(
      header: BrandTopBar(title: 'Reminders', leadingIcon: AppIcons.back),
      child: reminders.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: AppIcons.notifications,
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
                    child: Text(
                      Fmt.relativeDay(day),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  ...groups[day]!.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TintCard(
                        padding: EdgeInsets.zero,
                        child: BrandTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: r
                                  .accent(context.brand)
                                  .withValues(alpha: 0.13),
                              shape: BoxShape.circle,
                            ),
                            child: AppIcon(
                              r.icon,
                              size: 18,
                              color: r.accent(context.brand),
                            ),
                          ),
                          title: Text(
                            r.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            r.subtitle,
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Text(
                            Fmt.time(r.at),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () => context.push(r.route),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: BrandSpinner()),
        error: (e, _) =>
            EmptyState(icon: AppIcons.error, title: 'Error', message: '$e'),
      ),
    );
  }
}
