import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/modules.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/expenses_controller.dart';
import '../../state/focus_controller.dart';
import '../../state/habits_controller.dart';
import '../../state/medicine_controller.dart';
import '../../state/notes_controller.dart';
import '../../state/settings_controller.dart';
import '../../state/tasks_controller.dart';
import '../../widgets/common.dart';
import '../medicine/medicine_screen.dart';
import '../notes/notes_screen.dart';
import '../quick_add/quick_add_sheet.dart';
import '../search/search_screen.dart';
import '../tasks/tasks_screen.dart';

/// "Today" snapshot across every enabled module (spec 5 — Dashboard).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(),
                      style: context.text.bodySmall
                          ?.copyWith(color: context.muted)),
                  Text(Fmt.dateFull(DateTime.now()),
                      style: context.text.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.search),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
              sliver: SliverList.list(
                children: [
                  const _TodayStrip(),
                  const SizedBox(height: 20),
                  if (settings.isEnabled(ModuleId.medicine)) ...[
                    const _MedicineCard(),
                    const SizedBox(height: 14),
                  ],
                  if (settings.isEnabled(ModuleId.tasks)) ...[
                    const _TasksCard(),
                    const SizedBox(height: 14),
                  ],
                  if (settings.isEnabled(ModuleId.habits)) ...[
                    const _HabitsCard(),
                    const SizedBox(height: 14),
                  ],
                  if (settings.isEnabled(ModuleId.notes)) ...[
                    const _NotesCard(),
                    const SizedBox(height: 14),
                  ],
                  if (!_anyEnabled(settings))
                    const EmptyState(
                      icon: LucideIcons.layoutGrid,
                      title: 'No modules enabled',
                      message: 'Enable tools in Settings to see your day here.',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _anyEnabled(SettingsController s) => s.enabled.isNotEmpty;

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

/// Horizontal strip of headline numbers (spending, focus, etc.).
class _TodayStrip extends StatelessWidget {
  const _TodayStrip();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final tiles = <Widget>[];

    if (settings.isEnabled(ModuleId.focus)) {
      final focus = context.watch<FocusController>();
      tiles.add(StatTile(
        label: 'Focused today',
        value: Fmt.duration(Duration(seconds: focus.secondsToday())),
        icon: LucideIcons.timer,
        color: AppColors.focus,
      ));
    }
    if (settings.isEnabled(ModuleId.expenses)) {
      final exp = context.watch<ExpensesController>();
      tiles.add(StatTile(
        label: 'Spent today',
        value: Fmt.money(exp.spentToday()),
        icon: LucideIcons.wallet,
        color: AppColors.expenses,
      ));
    }
    if (settings.isEnabled(ModuleId.habits)) {
      final habits = context.watch<HabitsController>();
      tiles.add(StatTile(
        label: 'Habits done',
        value: '${habits.completedToday()}/${habits.count}',
        icon: LucideIcons.circleCheck,
        color: AppColors.habits,
      ));
    }
    if (settings.isEnabled(ModuleId.medicine)) {
      final med = context.watch<MedicineController>();
      tiles.add(StatTile(
        label: 'Doses left',
        value: '${med.remainingToday()}',
        icon: LucideIcons.pill,
        color: AppColors.medicine,
      ));
    }

    if (tiles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(width: 140, child: tiles[i]),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.module,
    required this.child,
    this.onTap,
  });

  final ModuleId module;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final info = moduleInfo(module);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(info.icon, color: info.accent, size: 32),
              const SizedBox(width: 10),
              Text(info.label,
                  style: context.text.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Icon(LucideIcons.chevronRight, size: 18, color: context.muted),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard();

  @override
  Widget build(BuildContext context) {
    final med = context.watch<MedicineController>();
    final next = med.nextDoseToday();
    return _DashCard(
      module: ModuleId.medicine,
      onTap: () => _open(context, const MedicineScreen()),
      child: next == null
          ? Text(
              med.count == 0
                  ? 'No medicines yet. Add a course to generate a schedule.'
                  : 'All doses done for today. 🎉',
              style: context.text.bodyMedium?.copyWith(color: context.muted),
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${next.medicine.name} · ${next.medicine.dosage}',
                          style: context.text.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        '${Fmt.timeOfDate(context, next.time)} · ${med.remainingToday()} left today',
                        style: context.text.bodySmall
                            ?.copyWith(color: context.muted),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => med.setTaken(next, true),
                  child: const Text('Take'),
                ),
              ],
            ),
    );
  }
}

class _TasksCard extends StatelessWidget {
  const _TasksCard();

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksController>();
    final due = tasks.dueToday().take(3).toList();
    return _DashCard(
      module: ModuleId.tasks,
      onTap: () => _open(context, const TasksScreen()),
      child: due.isEmpty
          ? Text('Nothing due today. Inbox: ${tasks.inbox().length} to sort.',
              style: context.text.bodyMedium?.copyWith(color: context.muted))
          : Column(
              children: [
                for (final t in due)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => tasks.toggleDone(t),
                          child: Icon(
                            t.done
                                ? LucideIcons.circleCheck
                                : LucideIcons.circle,
                            size: 20,
                            color: t.isOverdue
                                ? AppColors.dangerLight
                                : Color(t.priority.color),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyMedium),
                        ),
                        if (t.isOverdue)
                          Text('Overdue',
                              style: context.text.labelSmall?.copyWith(
                                  color: AppColors.dangerLight,
                                  fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _HabitsCard extends StatelessWidget {
  const _HabitsCard();

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsController>();
    final list = habits.habits.take(4).toList();
    return _DashCard(
      module: ModuleId.habits,
      onTap: () => QuickAddSheet.show(context),
      child: list.isEmpty
          ? Text('No habits yet. Track water, coffee, reading and more.',
              style: context.text.bodyMedium?.copyWith(color: context.muted))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in list)
                  ActionChip(
                    avatar: Icon(LucideIcons.plus,
                        size: 16, color: Color(h.color)),
                    label: Text(
                        '${h.name} ${h.amountOn(DateTime.now())}/${h.target}'),
                    onPressed: () => habits.log(h, h.step),
                  ),
              ],
            ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesController>();
    final recent = notes.recent();
    return _DashCard(
      module: ModuleId.notes,
      onTap: () => _open(context, const NotesScreen()),
      child: recent.isEmpty
          ? Text('No notes yet. Jot an idea or start a journal.',
              style: context.text.bodyMedium?.copyWith(color: context.muted))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final n in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      n.title.isEmpty ? n.preview : n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium,
                    ),
                  ),
              ],
            ),
    );
  }
}

void _open(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}
