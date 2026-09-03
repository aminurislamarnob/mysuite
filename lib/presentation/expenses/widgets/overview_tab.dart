import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/people/people_repository.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';
import 'accounts_sheet.dart';

class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final recent = ref.watch(recentExpensesProvider);
    final budgets = ref.watch(budgetProgressProvider).valueOrNull ?? const [];
    final overall = budgets
        .where((b) => b.budget.categoryId == null)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        const _SummaryCard(),
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

/// Balance, the month's in and out, and a way into the accounts — one card
/// instead of a card and a row of tiles, so the transactions start above
/// the fold.
class _SummaryCard extends ConsumerWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final balance = ref.watch(totalBalanceProvider);
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final report = ref.watch(monthReportProvider).valueOrNull;
    final muted = Theme.of(context).colorScheme.outline;

    final change = report?.changeVsPrevious;
    final changeLabel = change == null
        ? null
        : '${change >= 0 ? '+' : ''}${(change * 100).toStringAsFixed(0)}% vs last month';

    return TintCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Total balance',
                style: TextStyle(fontSize: 13, color: muted),
              ),
              const Spacer(),
              Text(
                Fmt.money(balance, currency),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Flow(
                  icon: AppIcons.arrowDown,
                  color: AppColors.successLight,
                  label: 'In',
                  value: report == null
                      ? '—'
                      : Fmt.compactMoney(report.income, currency),
                ),
              ),
              Expanded(
                child: _Flow(
                  icon: AppIcons.arrowUp,
                  color: AppColors.dangerLight,
                  label: 'Out',
                  value: report == null
                      ? '—'
                      : Fmt.compactMoney(report.expense, currency),
                  sublabel: changeLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          BrandTile(
            dense: true,
            leading: SizedBox(
              width: 24,
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  for (final a in accounts.take(4))
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Color(a.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            title: Text(
              accounts.length == 1
                  ? '1 account'
                  : '${accounts.length} accounts',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            trailing: const AppIcon(AppIcons.chevronRight),
            onTap: () => AccountsSheet.show(context),
          ),
        ],
      ),
    );
  }
}

/// One of the month's two figures inside the summary card.
class _Flow extends StatelessWidget {
  final HugeIconData icon;
  final Color color;
  final String label;
  final String value;
  final String? sublabel;

  const _Flow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outline;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: AppIcon(icon, color: color, size: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label this month',
                style: TextStyle(fontSize: 11, color: muted),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: TextStyle(fontSize: 10, color: muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
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
    final accounts = ref.watch(allAccountsProvider).valueOrNull ?? const [];
    final cat = categories.where((c) => c.id == tx.categoryId).firstOrNull;
    final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;
    final people = ref.watch(peopleProvider).valueOrNull ?? const [];
    final person = people.where((p) => p.id == tx.personId).firstOrNull;
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
        dense: true,
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
          '${account == null ? '' : ' · ${account.name}'}'
          // Self is the default, so saying so on every row is noise.
          '${person == null || person.isSelf ? '' : ' · ${person.name}'}',
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
