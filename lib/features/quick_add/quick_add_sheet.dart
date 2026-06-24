import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/modules.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../state/habits_controller.dart';
import '../../state/medicine_controller.dart';
import '../../state/settings_controller.dart';
import '../../state/tasks_controller.dart';
import '../../widgets/common.dart';
import '../expenses/add_expense_sheet.dart';
import '../focus/focus_screen.dart';
import '../notes/note_editor_screen.dart';

/// Unified Quick Add bottom sheet (spec 5 — Quick Add FAB). Frequent logs are
/// ≤2 taps: tap FAB → tap action.
class QuickAddSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _QuickAddBody(),
    );
  }
}

class _QuickAddBody extends StatefulWidget {
  const _QuickAddBody();

  @override
  State<_QuickAddBody> createState() => _QuickAddBodyState();
}

class _QuickAddBodyState extends State<_QuickAddBody> {
  final _taskCtrl = TextEditingController();

  @override
  void dispose() {
    _taskCtrl.dispose();
    super.dispose();
  }

  void _submitTask() {
    final text = _taskCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<TasksController>().quickAdd(text);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Task added')));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick add',
              style:
                  context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          if (settings.isEnabled(ModuleId.tasks)) ...[
            TextField(
              controller: _taskCtrl,
              autofocus: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitTask(),
              decoration: InputDecoration(
                hintText: 'Quick task — "Pay bill tomorrow #home !p1"',
                prefixIcon: const Icon(LucideIcons.listChecks),
                suffixIcon: IconButton(
                  icon: const Icon(LucideIcons.cornerDownLeft),
                  onPressed: _submitTask,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (settings.isEnabled(ModuleId.notes))
                _ActionButton(
                  icon: LucideIcons.notebookPen,
                  label: 'New note',
                  color: AppColors.notes,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const NoteEditorScreen()));
                  },
                ),
              if (settings.isEnabled(ModuleId.medicine))
                _ActionButton(
                  icon: LucideIcons.pill,
                  label: 'Take medicine',
                  color: AppColors.medicine,
                  onTap: _markMedicine,
                ),
              if (settings.isEnabled(ModuleId.habits))
                _ActionButton(
                  icon: LucideIcons.coffee,
                  label: 'Log habit',
                  color: AppColors.habits,
                  onTap: _logHabit,
                ),
              if (settings.isEnabled(ModuleId.expenses))
                _ActionButton(
                  icon: LucideIcons.wallet,
                  label: 'Add expense',
                  color: AppColors.expenses,
                  onTap: () {
                    Navigator.of(context).pop();
                    AddExpenseSheet.show(context);
                  },
                ),
              if (settings.isEnabled(ModuleId.focus))
                _ActionButton(
                  icon: LucideIcons.timer,
                  label: 'Start focus',
                  color: AppColors.focus,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const FocusScreen()));
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _markMedicine() {
    final med = context.read<MedicineController>();
    final next = med.nextDoseToday();
    Navigator.of(context).pop();
    if (next == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pending doses today')));
      return;
    }
    med.setTaken(next, true);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${next.medicine.name} marked as taken')));
  }

  void _logHabit() {
    final habits = context.read<HabitsController>().habits;
    if (habits.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add a habit first')));
      return;
    }
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final h in habits)
              ListTile(
                leading: IconBadge(LucideIcons.plus, color: Color(h.color)),
                title: Text(h.name),
                subtitle: Text(
                    '${h.amountOn(DateTime.now())} / ${h.target} ${h.unit}'),
                trailing: const Icon(LucideIcons.plus),
                onTap: () {
                  context.read<HabitsController>().log(h, h.step);
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 40 - 24) / 3;
    return SizedBox(
      width: width.clamp(96, 160),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            IconBadge(icon, color: color, size: 44),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: context.text.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
