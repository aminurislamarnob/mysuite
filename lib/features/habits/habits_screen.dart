import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/habit_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../models/habit.dart';
import '../../state/habits_controller.dart';
import '../../widgets/common.dart';
import 'add_habit_sheet.dart';
import 'habit_heatmap.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HabitsController>();
    final habits = controller.habits;

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddHabitSheet.show(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('New habit'),
      ),
      body: habits.isEmpty
          ? EmptyState(
              icon: LucideIcons.coffee,
              title: 'No habits yet',
              message:
                  'Track water, coffee, reading, exercise — build good ones, reduce the rest.',
              action: FilledButton.icon(
                onPressed: () => AddHabitSheet.show(context),
                icon: const Icon(LucideIcons.plus),
                label: const Text('New habit'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: habits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _HabitCard(habit: habits[i]),
            ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<HabitsController>();
    final color = Color(habit.color);
    final today = habit.amountOn(DateTime.now());
    final streak = habit.currentStreak();
    final over = habit.goal == HabitGoal.reduce && today > habit.target;

    return AppCard(
      onTap: () => AddHabitSheet.show(context, existing: habit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(habitIcon(habit.iconCode), color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name,
                        style: context.text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Icon(
                            habit.goal == HabitGoal.build
                                ? LucideIcons.trendingUp
                                : LucideIcons.trendingDown,
                            size: 13,
                            color: context.muted),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.goal.label} · ${habit.target} ${habit.unit}/day',
                          style: context.text.bodySmall
                              ?.copyWith(color: context.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (streak > 0)
                Row(
                  children: [
                    const Icon(LucideIcons.flame,
                        size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text('$streak',
                        style: context.text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => controller.log(habit, -habit.step),
                icon: const Icon(LucideIcons.minus),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$today / ${habit.target} ${habit.unit}',
                      style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: over ? const Color(0xFFEF4444) : color),
                    ),
                    const SizedBox(height: 6),
                    ProgressBar(
                      value: habit.progressOn(DateTime.now()),
                      color: over ? const Color(0xFFEF4444) : color,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => controller.log(habit, habit.step),
                icon: const Icon(LucideIcons.plus),
                style: IconButton.styleFrom(backgroundColor: color),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (over) ...[
            const SizedBox(height: 8),
            Text('Over your daily limit by ${today - habit.target} ${habit.unit}',
                style: context.text.labelSmall
                    ?.copyWith(color: const Color(0xFFEF4444))),
          ],
          const SizedBox(height: 14),
          HabitHeatmap(habit: habit, weeks: 16),
        ],
      ),
    );
  }
}
