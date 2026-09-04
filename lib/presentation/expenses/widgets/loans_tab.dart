import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';
import 'loan_sheet.dart';

/// Money lent and borrowed. The principal and every repayment are real
/// ledger rows, so balances stay right while none of it counts as spending.
class LoansTab extends ConsumerWidget {
  const LoansTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final rows = ref.watch(loanRowsProvider);
    final totals = ref.watch(loanTotalsProvider).valueOrNull;

    // The screen's own FAB owns the bottom corner, so the way to add a loan
    // sits in the list where it can be seen.
    return rows.when(
      loading: () => const Center(child: BrandSpinner()),
      error: (e, _) => Text('$e'),
      data: (loans) {
        final open = loans.where((r) => !r.isSettled).toList();
        final settled = loans.where((r) => r.isSettled).toList();

        if (loans.isEmpty) {
          return EmptyState(
            icon: AppIcons.transfer,
            title: 'No loans',
            message: 'Track what you lent out and what you owe.',
            actionLabel: 'Add a loan',
            onAction: () => LoanSheet.show(context),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            if (totals != null && (totals.owedToMe > 0 || totals.iOwe > 0)) ...[
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: AppIcons.arrowDown,
                      color: context.brand.success,
                      label: 'Owed to me',
                      value: Fmt.compactMoney(totals.owedToMe, currency),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: AppIcons.arrowUp,
                      color: context.brand.danger,
                      label: 'I owe',
                      value: Fmt.compactMoney(totals.iOwe, currency),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            ...open.map((r) => _LoanCard(row: r, currency: currency)),
            // The same pill the empty state offers, so the way to add a loan
            // does not change shape once there is one.
            Center(
              child: BrandButton(
                label: 'Add a loan',
                icon: AppIcons.add,
                expand: false,
                onPressed: () => LoanSheet.show(context),
              ),
            ),
            if (settled.isNotEmpty) ...[
              const SizedBox(height: 8),
              const SectionHeader('Settled'),
              ...settled.map((r) => _LoanCard(row: r, currency: currency)),
            ],
          ],
        );
      },
    );
  }
}

class _LoanCard extends ConsumerWidget {
  final LoanRow row;
  final String currency;

  const _LoanCard({required this.row, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = Theme.of(context).colorScheme.outline;
    final days = row.dueInDays;
    final overdue = !row.isSettled && days != null && days < 0;
    final color = row.isSettled
        ? muted
        : (row.isLent ? context.brand.success : context.brand.danger);

    final subtitle = [
      if (row.isSettled)
        'Settled'
      else
        '${Fmt.money(row.outstanding, currency)} of '
            '${Fmt.money(row.loan.principal, currency)} left',
      if (row.loan.dueDate != null && !row.isSettled)
        'due ${Fmt.relativeDay(row.loan.dueDate!)}',
      if (row.loan.note?.isNotEmpty == true) row.loan.note!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TintCard(
        padding: EdgeInsets.zero,
        child: TileGroup(
          children: [
            BrandTile(
              dense: true,
              leading: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  row.isLent ? AppIcons.arrowUp : AppIcons.arrowDown,
                  color: color,
                  size: 18,
                ),
              ),
              title: Text(
                row.person == null
                    ? (row.isLent ? 'Lent' : 'Borrowed')
                    : row.isLent
                    ? '${row.person!.name} owes me'
                    : 'I owe ${row.person!.name}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: overdue ? context.brand.danger : muted,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!row.isSettled)
                    BrandButton(
                      label: 'Repay',
                      kind: BrandButtonKind.ghost,
                      expand: false,
                      onPressed: () => RepaySheet.show(context, row),
                    ),
                  CircleIconButton(
                    icon: AppIcons.delete,
                    tooltip: 'Delete',
                    size: 40,
                    onPressed: () => _delete(context, ref),
                  ),
                ],
              ),
            ),
            if (!row.isSettled && row.repaid > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
                child: LabeledProgress(
                  label: 'Repaid',
                  trailing: Fmt.money(row.repaid, currency),
                  value: row.loan.principal == 0
                      ? 0
                      : row.repaid / row.loan.principal,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await brandConfirm(
      context,
      title: 'Delete this loan?',
      message:
          'Its principal and repayments are removed and the accounts '
          'get their money back.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok) {
      await ref.read(expenseRepositoryProvider).deleteLoan(row.loan.id);
    }
  }
}
