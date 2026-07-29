import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../expenses/providers/expenses_provider.dart';
import '../focus/providers/focus_provider.dart';
import '../habits/providers/habits_provider.dart';
import '../habits/utils/habit_stats.dart';
import '../medicine/providers/medicine_provider.dart';
import '../tasks/providers/tasks_provider.dart';

/// Cross-module weekly digest, assembled from real numbers rather than a
/// canned sentence.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currency = settings.currencySymbol;
    final muted = Theme.of(context).colorScheme.outline;

    final taskStats = ref.watch(taskStatsProvider(7)).valueOrNull;
    final focusStats = ref.watch(focusStatsProvider).valueOrNull;
    final adherence = ref.watch(adherenceProvider).valueOrNull;
    final report = ref.watch(monthReportProvider).valueOrNull;
    final habits = ref.watch(habitsListProvider).valueOrNull ?? const [];
    final caffeine = ref.watch(caffeineTodayProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
        children: [
          _DigestCard(
            lines: _buildDigest(
              ref,
              settings: settings,
              currency: currency,
              taskStats: taskStats,
              focusStats: focusStats,
              adherence: adherence,
              expense: report?.expense,
            ),
          ),
          const SizedBox(height: 24),

          if (settings.isEnabled(AppModule.tasks) && taskStats != null) ...[
            const SectionHeader('Tasks'),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    tintIndex: 0,
                    icon: AppIcons.checkCircle,
                    color: AppColors.taskAccent,
                    label: 'Completed (7d)',
                    value: '${taskStats.completed}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    tintIndex: 1,
                    icon: AppIcons.pending,
                    color: AppColors.warningLight,
                    label: 'Still open',
                    value: '${taskStats.open}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    tintIndex: 2,
                    icon: AppIcons.error,
                    color: AppColors.dangerLight,
                    label: 'Overdue',
                    value: '${taskStats.overdue}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Completion heatmap',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 7 * 17.0,
              child: ContributionHeatmap(
                color: AppColors.taskAccent,
                intensityFor: (day) {
                  final n = taskStats.perDay[Fmt.dateOnly(day)] ?? 0;
                  return n == 0 ? 0 : (n / 5).clamp(0.2, 1.0);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (settings.isEnabled(AppModule.medicine) && adherence != null) ...[
            const SectionHeader('Medicine adherence'),
            LabeledProgress(
              label: 'Last 30 days',
              trailing: Fmt.percent(adherence.monthly),
              value: adherence.monthly,
              color: adherence.monthly >= 0.9
                  ? AppColors.successLight
                  : AppColors.warningLight,
            ),
            if (adherence.totalMisses > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'You missed ${adherence.totalMisses} dose'
                  '${adherence.totalMisses == 1 ? '' : 's'}'
                  '${adherence.worstWeekday == null ? '' : ' — mostly ${_weekdayName(adherence.worstWeekday!)}s'}.',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ),
            const SizedBox(height: 24),
          ],

          if (settings.isEnabled(AppModule.focus) && focusStats != null) ...[
            const SectionHeader('Focus'),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    tintIndex: 3,
                    icon: AppIcons.focus,
                    color: AppColors.focusAccent,
                    label: 'This week',
                    value: Fmt.duration(focusStats.week),
                    sublabel: '${focusStats.sessionsWeek} sessions',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    tintIndex: 4,
                    icon: AppIcons.lightMode,
                    color: AppColors.warningLight,
                    label: 'Peak hour',
                    value: focusStats.bestHour == null
                        ? '—'
                        : Fmt.minutesOfDay(focusStats.bestHour! * 60),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          if (settings.isEnabled(AppModule.expenses) && report != null) ...[
            const SectionHeader('Money this month'),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    tintIndex: 5,
                    icon: AppIcons.arrowUp,
                    color: AppColors.dangerLight,
                    label: 'Spent',
                    value: Fmt.compactMoney(report.expense, currency),
                    sublabel: report.changeVsPrevious == null
                        ? null
                        : '${report.changeVsPrevious! >= 0 ? '+' : ''}'
                            '${(report.changeVsPrevious! * 100).toStringAsFixed(0)}% vs last',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    tintIndex: 6,
                    icon: AppIcons.savings,
                    color: report.net >= 0
                        ? AppColors.successLight
                        : AppColors.dangerLight,
                    label: 'Net',
                    value: Fmt.compactMoney(report.net, currency),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          if (settings.isEnabled(AppModule.habits) && habits.isNotEmpty) ...[
            const SectionHeader('Habits'),
            ...habits.map((h) {
              final stats = ref.watch(habitStatsProvider(h.id)).valueOrNull ??
                  HabitStats.empty;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LabeledProgress(
                  label: h.name,
                  trailing:
                      '${stats.currentStreak}d streak · ${Fmt.percent(stats.completionRate)}',
                  value: stats.completionRate,
                  color: Color(h.color),
                ),
              );
            }),
            if (caffeine > 0)
              Text('Caffeine today: ${caffeine.toStringAsFixed(0)} mg',
                  style: TextStyle(fontSize: 12, color: muted)),
          ],
        ],
      ),
    );
  }

  /// Builds the digest sentences, skipping modules the user has turned off and
  /// anything with no data behind it.
  List<String> _buildDigest(
    WidgetRef ref, {
    required AppSettings settings,
    required String currency,
    TaskStats? taskStats,
    FocusStats? focusStats,
    AdherenceStats? adherence,
    double? expense,
  }) {
    final lines = <String>[];

    if (settings.isEnabled(AppModule.tasks) &&
        taskStats != null &&
        taskStats.completed > 0) {
      lines.add('✅ ${taskStats.completed} tasks completed this week');
    }
    if (settings.isEnabled(AppModule.focus) &&
        focusStats != null &&
        focusStats.week > Duration.zero) {
      lines.add('⏱ ${Fmt.duration(focusStats.week)} focused');
    }
    if (settings.isEnabled(AppModule.expenses) &&
        expense != null &&
        expense > 0) {
      lines.add('💰 ${Fmt.money(expense, currency)} spent this month');
    }
    if (settings.isEnabled(AppModule.medicine) && adherence != null) {
      lines.add('💊 ${Fmt.percent(adherence.weekly)} medicine adherence');
    }
    if (settings.isEnabled(AppModule.habits)) {
      final habits = ref.watch(habitsListProvider).valueOrNull ?? const [];
      final today = ref.watch(todayHabitLogsProvider).valueOrNull ?? const {};
      final done = habits.where((h) {
        final amount = today[h.id] ?? 0;
        return h.goalType == 0
            ? amount >= h.targetAmount
            : amount <= h.targetAmount;
      }).length;
      if (habits.isNotEmpty) {
        lines.add('☕ $done of ${habits.length} habits on track today');
      }
    }

    if (adherence != null &&
        adherence.worstWeekday != null &&
        adherence.totalMisses >= 2) {
      lines.add(
          '⚠️ Doses slip most on ${_weekdayName(adherence.worstWeekday!)}s');
    }

    return lines;
  }

  static String _weekdayName(int weekday) => const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][(weekday - 1).clamp(0, 6)];
}

class _DigestCard extends StatelessWidget {
  final List<String> lines;
  const _DigestCard({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppIcon(AppIcons.sparkle,
                    size: 18, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Text('This week',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            if (lines.isEmpty)
              Text(
                'Not enough data yet. Log a few things and your weekly digest '
                'will appear here.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline, fontSize: 13),
              )
            else
              ...lines.map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(l, style: const TextStyle(fontSize: 14)),
                  )),
          ],
        ),
      ),
    );
  }
}
