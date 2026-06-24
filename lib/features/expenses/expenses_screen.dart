import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/expense_categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/expense.dart';
import '../../state/expenses_controller.dart';
import '../../widgets/common.dart';
import 'add_expense_sheet.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExpensesController>();
    final txns = controller.month(DateTime.now());
    final byCat = controller.byCategory(DateTime.now());
    final spent = controller.spentThisMonth();

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddExpenseSheet.show(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          _SummaryCard(
            spent: spent,
            income: controller.incomeThisMonth(),
            balance: controller.balance,
          ),
          const SizedBox(height: 16),
          if (byCat.isNotEmpty) ...[
            const SectionHeader('This month by category',
                icon: LucideIcons.chartPie),
            AppCard(
              child: _CategoryBreakdown(entries: byCat, total: spent),
            ),
            const SizedBox(height: 16),
          ],
          const SectionHeader('Transactions', icon: LucideIcons.receipt),
          if (txns.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: LucideIcons.wallet,
                title: 'No transactions yet',
                message: 'Log spending in 2 taps with the + button.',
              ),
            )
          else
            for (final e in txns) _TxnTile(expense: e),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.spent,
    required this.income,
    required this.balance,
  });
  final double spent;
  final double income;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.expenses.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Fmt.month(DateTime.now()),
              style: context.text.labelMedium?.copyWith(color: context.muted)),
          const SizedBox(height: 4),
          Text('Spent ${Fmt.money(spent)}',
              style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.expenses)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniStat(context, LucideIcons.trendingUp, 'Income',
                    Fmt.money(income), AppColors.successLight),
              ),
              Container(
                  width: 1, height: 32, color: context.muted.withValues(alpha: 0.2)),
              Expanded(
                child: _miniStat(
                    context,
                    LucideIcons.wallet,
                    'Balance',
                    Fmt.money(balance),
                    balance >= 0
                        ? AppColors.successLight
                        : AppColors.dangerLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(BuildContext context, IconData icon, String label,
      String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: context.text.labelSmall?.copyWith(color: context.muted)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            style: context.text.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.entries, required this.total});
  final List<MapEntry<String, double>> entries;
  final double total;

  @override
  Widget build(BuildContext context) {
    final top = entries.take(6).toList();
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: [
                for (final e in top)
                  PieChartSectionData(
                    value: e.value,
                    color: Color(categoryMeta(e.key).color),
                    radius: 24,
                    showTitle: false,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              for (final e in top)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(categoryMeta(e.key).color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(e.key,
                              style: context.text.bodySmall,
                              overflow: TextOverflow.ellipsis)),
                      Text(Fmt.money(e.value),
                          style: context.text.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta(expense.category, income: expense.isIncome);
    final color = Color(meta.color);
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444)),
      ),
      onDismissed: (_) =>
          context.read<ExpensesController>().delete(expense.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            IconBadge(meta.icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.category,
                      style: context.text.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    '${expense.account.label} · ${Fmt.relativeDay(expense.date)}'
                    '${expense.note.isNotEmpty ? ' · ${expense.note}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        context.text.bodySmall?.copyWith(color: context.muted),
                  ),
                ],
              ),
            ),
            Text(
              '${expense.isIncome ? '+' : '-'}${Fmt.money(expense.amount)}',
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: expense.isIncome
                    ? AppColors.successLight
                    : context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
