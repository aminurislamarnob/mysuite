import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/modules.dart';
import '../../core/theme/app_theme.dart';
import '../../state/expenses_controller.dart';
import '../../state/habits_controller.dart';
import '../../state/medicine_controller.dart';
import '../../state/notes_controller.dart';
import '../../state/settings_controller.dart';
import '../../state/tasks_controller.dart';
import '../../widgets/common.dart';
import '../expenses/expenses_screen.dart';
import '../focus/focus_screen.dart';
import '../habits/habits_screen.dart';
import '../medicine/medicine_screen.dart';
import '../notes/notes_screen.dart';
import '../tasks/tasks_screen.dart';

/// Grid of enabled modules; each tile shows a live count and opens the module.
class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final enabled = settings.enabledModules;

    return Scaffold(
      appBar: AppBar(title: const Text('Modules')),
      body: enabled.isEmpty
          ? const EmptyState(
              icon: LucideIcons.layoutGrid,
              title: 'No modules enabled',
              message: 'Turn tools on in Settings to start using them.',
            )
          : GridView.count(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: [
                for (final m in enabled)
                  _ModuleTile(
                    info: m,
                    subtitle: _subtitle(context, m.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _screenFor(m.id)),
                    ),
                  ),
              ],
            ),
    );
  }

  static String _subtitle(BuildContext context, ModuleId id) {
    switch (id) {
      case ModuleId.notes:
        return '${context.watch<NotesController>().count} notes';
      case ModuleId.medicine:
        final m = context.watch<MedicineController>();
        return '${m.count} meds · ${m.remainingToday()} due';
      case ModuleId.habits:
        final h = context.watch<HabitsController>();
        return '${h.completedToday()}/${h.count} today';
      case ModuleId.tasks:
        final t = context.watch<TasksController>();
        return '${t.openCount} open · ${t.dueTodayCount} due';
      case ModuleId.expenses:
        return 'Bal ${_short(context.watch<ExpensesController>().balance)}';
      case ModuleId.focus:
        return 'Pomodoro & deep work';
    }
  }

  static String _short(double v) {
    if (v.abs() >= 1000) return '৳${(v / 1000).toStringAsFixed(1)}k';
    return '৳${v.toStringAsFixed(0)}';
  }

  static Widget _screenFor(ModuleId id) => switch (id) {
        ModuleId.notes => const NotesScreen(),
        ModuleId.medicine => const MedicineScreen(),
        ModuleId.habits => const HabitsScreen(),
        ModuleId.tasks => const TasksScreen(),
        ModuleId.expenses => const ExpensesScreen(),
        ModuleId.focus => const FocusScreen(),
      };
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.info,
    required this.subtitle,
    required this.onTap,
  });

  final ModuleInfo info;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(info.icon, color: info.accent, size: 48),
          const Spacer(),
          Text(info.label,
              style: context.text.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(color: context.muted)),
        ],
      ),
    );
  }
}
