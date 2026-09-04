import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import 'month_stepper.dart';

class ReportsTab extends ConsumerWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final reportAsync = ref.watch(monthReportProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final trend = ref.watch(monthlyTrendProvider).valueOrNull ?? const [];
    final byPerson = ref.watch(spendByPersonProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        const MonthStepper(),
        reportAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: BrandSpinner()),
          ),
          error: (e, _) => Text('$e'),
          data: (report) {
            if (report.expense == 0 && report.income == 0) {
              return const EmptyState(
                icon: AppIcons.barChart,
                title: 'Nothing recorded this month',
              );
            }

            final slices = report.byCategory.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: AppIcons.arrowDown,
                        color: context.brand.success,
                        label: 'Income',
                        value: Fmt.compactMoney(report.income, currency),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: AppIcons.arrowUp,
                        color: context.brand.danger,
                        label: 'Expense',
                        value: Fmt.compactMoney(report.expense, currency),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: AppIcons.savings,
                        color: report.net >= 0
                            ? context.brand.success
                            : context.brand.danger,
                        label: 'Net',
                        value: Fmt.compactMoney(report.net, currency),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionHeader('Spending by category'),
                if (slices.isEmpty)
                  const Text('No expenses this month.')
                else ...[
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 46,
                        sectionsSpace: 2,
                        sections: slices.take(8).map((entry) {
                          final cat = categories
                              .where((c) => c.id == entry.key)
                              .firstOrNull;
                          final share = entry.value / report.expense;
                          return PieChartSectionData(
                            color: Color(cat?.color ?? 0xFF6C6C6C),
                            value: entry.value,
                            radius: 52,
                            title: share < 0.07 ? '' : Fmt.percent(share),
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...slices.map((entry) {
                    final cat = categories
                        .where((c) => c.id == entry.key)
                        .firstOrNull;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LabeledProgress(
                        label: cat?.name ?? 'Uncategorised',
                        trailing: Fmt.money(entry.value, currency),
                        value: entry.value / report.expense,
                        color: Color(cat?.color ?? 0xFF6C6C6C),
                      ),
                    );
                  }),
                ],
                if (byPerson.length > 1) ...[
                  const SizedBox(height: 24),
                  const SectionHeader('Spending by person'),
                  ...byPerson.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LabeledProgress(
                        label: e.person.isSelf ? 'Me' : e.person.name,
                        trailing: Fmt.money(e.amount, currency),
                        value: report.expense == 0
                            ? 0
                            : e.amount / report.expense,
                        color: Color(e.person.color),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const SectionHeader('Last 6 months'),
                if (trend.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, _) {
                                final i = value.toInt();
                                if (i < 0 || i >= trend.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    Fmt.monthYear(
                                      trend[i].month,
                                    ).split(' ')[0].substring(0, 3),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < trend.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: trend[i].expense,
                                  color: context.brand.expense,
                                  width: 10,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                BarChartRodData(
                                  toY: trend[i].income,
                                  color: context.brand.success,
                                  width: 10,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legend(context.brand.expense, 'Expense'),
                    const SizedBox(width: 16),
                    _legend(context.brand.success, 'Income'),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
