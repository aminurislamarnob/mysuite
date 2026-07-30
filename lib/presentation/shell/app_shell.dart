import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
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

    // The bar is stacked over the body rather than placed in FScaffold's footer
    // slot: it draws its own background, floats the action button above the
    // notch, and the body has to show through that notch. That is Material's
    // `extendBody`, which FScaffold has no equivalent for — a footer would push
    // the body up instead. Screens already reserve bottom padding for the bar.
    return BrandScaffold(
      child: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CurvedNavBar(
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
            selectedIcon: AppIcons.dashboard,
            label: 'Today',
          ),
          CurvedNavItem(
            icon: AppIcons.modules,
            selectedIcon: AppIcons.modules,
            label: 'Modules',
          ),
          CurvedNavItem(
            icon: AppIcons.insights,
            selectedIcon: AppIcons.insights,
            label: 'Insights',
          ),
          CurvedNavItem(
            icon: AppIcons.settings,
            selectedIcon: AppIcons.settings,
            label: 'Settings',
          ),
        ],
      ),
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
    return FTooltip(
      tipBuilder: (_, _) => const Text('Quick add'),
      semanticsLabel: 'Quick add',
      child: FTappable(
        onPress: onPressed,
        semanticsLabel: 'Quick add',
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: primary,
            shape: const CircleBorder(),
            shadows: [
              BoxShadow(
                color: primary.withValues(alpha: 0.28),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const SizedBox(
            width: 58,
            height: 58,
            child: AppIcon(AppIcons.add, color: Colors.white, size: 30),
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

  return brandSheet(
    context: context,
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
              icon: AppIcons.transfer,
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
  required HugeIconData icon,
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
              child: AppIcon(icon, color: Colors.white, size: 21),
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
            AppIcon(AppIcons.chevronRight, color: context.muted),
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
    brandToast(context, 'No habits yet — add one first.');
    return;
  }

  await brandSheet(
    context: context,
    builder: (sheetContext) => SheetScaffold(
      title: 'Log a habit',
      child: Column(
        children: habits.map((h) {
          return BrandTile(
            leading: AppIcon(AppIcons.habit(h.icon), color: Color(h.color)),
            title: Text(h.name),
            subtitle: h.unit == null
                ? null
                : Text('+1 ${h.unit}', style: const TextStyle(fontSize: 11)),
            trailing: AppIcon(AppIcons.addCircle, color: Color(h.color)),
            onTap: () async {
              await ref.read(habitRepositoryProvider).addToDay(h.id, 1);
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (context.mounted) {
                brandToast(context, 'Logged ${h.name}.');
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
    brandToast(context, 'No pending doses today.');
    return;
  }

  await brandSheet(
    context: context,
    builder: (sheetContext) => SheetScaffold(
      title: 'Mark taken',
      child: Column(
        children: doses.map((v) {
          return BrandTile(
            leading: AppIcon(AppIcons.medicineForm(v.medicine.form),
                color: AppColors.medicineAccent),
            title: Text(v.medicine.name),
            subtitle: Text(
              '${v.dosageLabel}${v.mealLabel.isEmpty ? '' : ' · ${v.mealLabel}'}',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const AppIcon(AppIcons.checkCircle),
            onTap: () async {
              await ref
                  .read(medicineRepositoryProvider)
                  .setDoseStatus(v.dose.id, DoseStatus.taken);
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (context.mounted) {
                brandToast(context, '${v.medicine.name} marked taken.');
              }
            },
          );
        }).toList(),
      ),
    ),
  );
}
