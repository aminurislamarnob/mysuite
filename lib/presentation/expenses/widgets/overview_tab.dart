import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';

class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final balance = ref.watch(totalBalanceProvider);
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final recent = ref.watch(recentExpensesProvider);
    final report = ref.watch(monthReportProvider).valueOrNull;
    final budgets = ref.watch(budgetProgressProvider).valueOrNull ?? const [];
    final overall = budgets
        .where((b) => b.budget.categoryId == null)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        TintCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total balance',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Fmt.money(balance, currency),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: accounts
                      .map(
                        (a) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppIcon(
                                  AppIcons.account(a.type),
                                  size: 13,
                                  color: Color(a.color),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  a.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Fmt.money(a.balance, currency),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (report != null)
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: AppIcons.arrowDown,
                  color: AppColors.successLight,
                  label: 'Income this month',
                  value: Fmt.compactMoney(report.income, currency),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: AppIcons.arrowUp,
                  color: AppColors.dangerLight,
                  label: 'Spent this month',
                  value: Fmt.compactMoney(report.expense, currency),
                  sublabel: report.changeVsPrevious == null
                      ? null
                      : '${report.changeVsPrevious! >= 0 ? '+' : ''}'
                            '${(report.changeVsPrevious! * 100).toStringAsFixed(0)}% vs last month',
                ),
              ),
            ],
          ),
        if (overall != null) ...[
          const SizedBox(height: 20),
          LabeledProgress(
            label: 'Monthly budget',
            trailing:
                '${Fmt.money(overall.spent, currency)} / ${Fmt.money(overall.budget.amount, currency)}',
            value: overall.fraction,
            color: overall.alertTier >= 80
                ? AppColors.warningLight
                : AppColors.successLight,
          ),
        ],
        const SizedBox(height: 24),
        const SectionHeader('Recent transactions'),
        recent.when(
          data: (rows) => rows.isEmpty
              ? const EmptyState(
                  icon: AppIcons.bills,
                  title: 'No transactions yet',
                  message: 'Tap Add to record your first one.',
                )
              : Column(children: rows.map((e) => _TxTile(tx: e)).toList()),
          loading: () => const Center(child: BrandSpinner()),
          error: (e, _) => Text('$e'),
        ),
      ],
    );
  }
}

class _TxTile extends ConsumerWidget {
  final Expense tx;
  const _TxTile({required this.tx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final cat = categories.where((c) => c.id == tx.categoryId).firstOrNull;
    final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;
    final muted = Theme.of(context).colorScheme.outline;

    final color = switch (tx.kind) {
      TxKind.income => AppColors.successLight,
      TxKind.transfer => AppColors.primaryLight,
      _ => Color(cat?.color ?? 0xFF6C6C6C),
    };
    final icon = switch (tx.kind) {
      TxKind.income => AppIcons.arrowDown,
      TxKind.transfer => AppIcons.transfer,
      _ => AppIcons.category(cat?.icon ?? 'other'),
    };
    final sign = switch (tx.kind) {
      TxKind.income => '+',
      TxKind.transfer => '',
      _ => '-',
    };

    return Dismissible(
      key: ValueKey('tx-${tx.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const AppIcon(AppIcons.delete, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(expenseRepositoryProvider).deleteTransaction(tx.id),
      child: BrandTile(
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: AppIcon(icon, color: color, size: 18),
        ),
        title: Text(
          tx.note?.isNotEmpty == true
              ? tx.note!
              : cat?.name ??
                    (tx.kind == TxKind.transfer ? 'Transfer' : 'Expense'),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${Fmt.relativeDay(tx.date)}'
          '${account == null ? '' : ' · ${account.name}'}',
          style: TextStyle(fontSize: 11, color: muted),
        ),
        trailing: Text(
          '$sign${Fmt.money(tx.amount, currency)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: tx.kind == TxKind.income ? AppColors.successLight : null,
          ),
        ),
      ),
    );
  }
}
