import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../expenses/repository/expense_repository.dart';
import '../expenses/widgets/expense_entry_sheet.dart';
import '../habits/providers/habits_provider.dart';
import '../habits/repository/habit_repository.dart';
import '../medicine/providers/medicine_provider.dart';
import '../medicine/repository/medicine_repository.dart';
import '../notes/notes_screen.dart' show newNoteFlow;
import '../tasks/widgets/task_editor_sheet.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceMotion = ref.watch(settingsProvider).reduceMotion;

    final body = reduceMotion
        ? navigationShell
        : navigationShell
            .animate(key: ValueKey(navigationShell.currentIndex))
            .fadeIn(duration: 220.ms)
            .slideY(begin: 0.03, end: 0, curve: Curves.easeOutQuart);

    return Scaffold(
      // The curved bar draws its own background and floats the action button
      // over the notch, so it is the body's bottom chrome rather than a
      // Material NavigationBar.
      extendBody: true,
      body: body,
      bottomNavigationBar: CurvedNavBar(
        currentIndex: navigationShell.currentIndex,
        onSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        centerAction: QuickAddButton(
          onPressed: () => showQuickAdd(context, ref),
        ),
        items: const [
          CurvedNavItem(
            icon: AppIcons.dashboard,
            selectedIcon: Icons.grid_view_rounded,
            label: 'Today',
          ),
          CurvedNavItem(
            icon: AppIcons.modules,
            selectedIcon: Icons.apps_rounded,
            label: 'Modules',
          ),
          CurvedNavItem(
            icon: AppIcons.insights,
            selectedIcon: Icons.insights_rounded,
            label: 'Insights',
          ),
          CurvedNavItem(
            icon: AppIcons.settings,
            selectedIcon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// The round coral `+` that sits in the notch of the bottom bar.
class QuickAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const QuickAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      label: 'Quick add',
      child: Tooltip(
        message: 'Quick add',
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.28),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: primary,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: const SizedBox(
                width: 58,
                height: 58,
                child: Icon(Icons.add_rounded, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The Quick Add sheet. Every entry here is a real action, and the frequent
/// ones (log habit, mark dose) complete in a single extra tap.
Future<void> showQuickAdd(BuildContext context, WidgetRef ref) {
  final settings = ref.read(settingsProvider);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SheetScaffold(
      title: 'Quick add',
      child: Column(
        children: [
          if (settings.isEnabled(AppModule.tasks))
            _tile(
              icon: AppIcons.tasks,
              color: AppColors.taskAccent,
              title: 'Add task',
              onTap: () {
                Navigator.pop(sheetContext);
                TaskEditorSheet.show(context);
              },
            ),
          if (settings.isEnabled(AppModule.expenses))
            _tile(
              icon: AppIcons.expenses,
              color: AppColors.expenseAccent,
              title: 'Add expense',
              onTap: () {
                Navigator.pop(sheetContext);
                ExpenseEntrySheet.show(context);
              },
            ),
          if (settings.isEnabled(AppModule.habits))
            _tile(
              icon: AppIcons.habits,
              color: AppColors.habitAccent,
              title: 'Log habit',
              subtitle: 'One tap per habit',
              onTap: () {
                Navigator.pop(sheetContext);
                _showHabitPicker(context, ref);
              },
            ),
          if (settings.isEnabled(AppModule.medicine))
            _tile(
              icon: AppIcons.medicine,
              color: AppColors.medicineAccent,
              title: 'Mark medicine taken',
              onTap: () {
                Navigator.pop(sheetContext);
                _showDosePicker(context, ref);
              },
            ),
          if (settings.isEnabled(AppModule.notes))
            _tile(
              icon: AppIcons.notes,
              color: AppColors.noteAccent,
              title: 'New note',
              onTap: () {
                Navigator.pop(sheetContext);
                newNoteFlow(context, ref);
              },
            ),
          if (settings.isEnabled(AppModule.focus))
            _tile(
              icon: AppIcons.focus,
              color: AppColors.focusAccent,
              title: 'Start focus session',
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/focus');
              },
            ),
          if (settings.isEnabled(AppModule.expenses))
            _tile(
              icon: Icons.swap_horiz,
              color: AppColors.primaryLight,
              title: 'Transfer money',
              onTap: () {
                Navigator.pop(sheetContext);
                ExpenseEntrySheet.show(context, kind: TxKind.transfer);
              },
            ),
        ],
      ),
    ),
  );
}

/// One row of the Quick Add sheet, on the same tinted-card chrome as the rest
/// of the app.
Widget _tile({
  required IconData icon,
  required Color color,
  required String title,
  String? subtitle,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Builder(
      builder: (context) => TintCard(
        accent: color,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  if (subtitle != null)
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 12, color: context.muted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.muted),
          ],
        ),
      ),
    ),
  );
}

/// Second tap of the 2-tap habit log.
Future<void> _showHabitPicker(BuildContext context, WidgetRef ref) async {
  final habits = ref.read(habitsListProvider).valueOrNull ?? const [];
  if (habits.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No habits yet — add one first.')),
    );
    return;
  }

  await showModalBottomSheet(
    context: context,
    builder: (sheetContext) => SheetScaffold(
      title: 'Log a habit',
      child: Column(
        children: habits.map((h) {
          return ListTile(
            leading: Icon(AppIcons.habit(h.icon), color: Color(h.color)),
            title: Text(h.name),
            subtitle: h.unit == null
                ? null
                : Text('+1 ${h.unit}', style: const TextStyle(fontSize: 11)),
            trailing: Icon(Icons.add_circle, color: Color(h.color)),
            onTap: () async {
              await ref.read(habitRepositoryProvider).addToDay(h.id, 1);
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged ${h.name}.')),
                );
              }
            },
          );
        }).toList(),
      ),
    ),
  );
}

/// Second tap of the 2-tap dose log.
Future<void> _showDosePicker(BuildContext context, WidgetRef ref) async {
  final doses = (ref.read(todayDoseViewsProvider).valueOrNull ?? const [])
      .where((d) => d.status == DoseStatus.pending)
      .toList();

  if (doses.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No pending doses today.')),
    );
    return;
  }

  await showModalBottomSheet(
    context: context,
    builder: (sheetContext) => SheetScaffold(
      title: 'Mark taken',
      child: Column(
        children: doses.map((v) {
          return ListTile(
            leading: Icon(AppIcons.medicineForm(v.medicine.form),
                color: AppColors.medicineAccent),
            title: Text(v.medicine.name),
            subtitle: Text(
              '${v.dosageLabel}${v.mealLabel.isEmpty ? '' : ' · ${v.mealLabel}'}',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.check_circle_outline),
            onTap: () async {
              await ref
                  .read(medicineRepositoryProvider)
                  .setDoseStatus(v.dose.id, DoseStatus.taken);
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${v.medicine.name} marked taken.')),
                );
              }
            },
          );
        }).toList(),
      ),
    ),
  );
}
