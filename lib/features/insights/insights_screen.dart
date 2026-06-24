import 'package:fl_chart/fl_chart.dart';
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
import '../../state/settings_controller.dart';
import '../../state/tasks_controller.dart';
import '../../widgets/common.dart';

/// Cross-module weekly digest (spec 5 — Insights / Weekly AI Digest).
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final focus = context.watch<FocusController>();
    final expenses = context.watch<ExpensesController>();
    final habits = context.watch<HabitsController>();
    final med = context.watch<MedicineController>();
    final tasks = context.watch<TasksController>();

    final digest = _digest(context, settings, focus, expenses, habits, med, tasks);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          AppCard(
            color: context.colors.primary.withValues(alpha: 0.10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(LucideIcons.sparkles,
                        color: context.colors.primary, size: 36),
                    const SizedBox(width: 10),
                    Text('This week',
                        style: context.text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(digest,
                    style: context.text.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (settings.isEnabled(ModuleId.focus)) ...[
            const SectionHeader('Focus · last 7 days',
                icon: LucideIcons.timer),
            AppCard(
              child: _WeeklyBars(
                values: focus
                    .dailyHistory(7)
                    .map((s) => s / 3600)
                    .toList(),
                color: AppColors.focus,
                unit: 'h',
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (settings.isEnabled(ModuleId.expenses)) ...[
            const SectionHeader('Spending · last 7 days',
                icon: LucideIcons.wallet),
            AppCard(
              child: _WeeklyBars(
                values: expenses.dailySpend(7),
                color: AppColors.expenses,
                unit: '৳',
                asMoney: true,
              ),
            ),
            const SizedBox(height: 20),
          ],
          const SectionHeader('At a glance', icon: LucideIcons.gauge),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              if (settings.isEnabled(ModuleId.medicine))
                StatTile(
                  label: 'Med adherence',
                  value: '${(med.overallAdherence() * 100).round()}%',
                  icon: LucideIcons.pill,
                  color: AppColors.medicine,
                ),
              if (settings.isEnabled(ModuleId.tasks))
                StatTile(
                  label: 'Open tasks',
                  value: '${tasks.openCount}',
                  icon: LucideIcons.listChecks,
                  color: AppColors.tasks,
                ),
              if (settings.isEnabled(ModuleId.habits))
                StatTile(
                  label: 'Habits today',
                  value: '${habits.completedToday()}/${habits.count}',
                  icon: LucideIcons.coffee,
                  color: AppColors.habits,
                ),
              if (settings.isEnabled(ModuleId.focus))
                StatTile(
                  label: 'Focus this week',
                  value: Fmt.duration(
                      Duration(seconds: focus.secondsThisWeek())),
                  icon: LucideIcons.timer,
                  color: AppColors.focus,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _digest(
    BuildContext context,
    SettingsController settings,
    FocusController focus,
    ExpensesController expenses,
    HabitsController habits,
    MedicineController med,
    TasksController tasks,
  ) {
    final parts = <String>[];
    if (settings.isEnabled(ModuleId.focus)) {
      parts.add('${Fmt.duration(Duration(seconds: focus.secondsThisWeek()))} focused');
    }
    if (settings.isEnabled(ModuleId.expenses)) {
      final spent = expenses
          .dailySpend(7)
          .fold<double>(0, (s, v) => s + v);
      parts.add('${Fmt.money(spent)} spent');
    }
    if (settings.isEnabled(ModuleId.medicine) && med.count > 0) {
      parts.add('${(med.overallAdherence() * 100).round()}% medicine adherence');
    }
    if (settings.isEnabled(ModuleId.habits) && habits.count > 0) {
      parts.add('${habits.completedToday()} habits completed today');
    }
    if (settings.isEnabled(ModuleId.tasks)) {
      parts.add('${tasks.openCount} tasks still open');
    }
    if (parts.isEmpty) {
      return 'Start logging across your modules and your weekly digest will appear here.';
    }
    return '${parts.join(', ')}. Keep it up — small steps compound.';
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({
    required this.values,
    required this.color,
    required this.unit,
    this.asMoney = false,
  });

  final List<double> values;
  final Color color;
  final String unit;
  final bool asMoney;

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final today = DateTime.now();
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxV <= 0 ? 1 : maxV * 1.25,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= values.length) return const SizedBox();
                  final d = today.subtract(Duration(days: values.length - 1 - i));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(Fmt.weekday(d).substring(0, 1),
                        style: context.text.labelSmall
                            ?.copyWith(color: context.muted)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: color,
                  width: 16,
                  borderRadius: BorderRadius.circular(6),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}
