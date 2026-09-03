import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';
import 'month_stepper.dart';

/// Caps for one month. A month starts empty and is filled either by setting
/// caps or by copying the last month that had any.
class BudgetsTab extends ConsumerWidget {
  const BudgetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final progress = ref.watch(budgetProgressProvider);

    // The screen's own FAB owns the bottom corner, so the way to add a cap
    // sits in the list where it can be seen.
    return progress.when(
      loading: () => const Center(child: BrandSpinner()),
      error: (e, _) => Text('$e'),
      data: (rows) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const MonthStepper(),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            _EmptyMonth(onSet: () => _editBudget(context, ref))
          else ...[
            ...rows.map(
              (p) => _BudgetRow(
                progress: p,
                currency: currency,
                onEdit: () => _editBudget(context, ref, existing: p),
              ),
            ),
            BrandButton(
              label: 'Add a budget',
              icon: AppIcons.add,
              kind: BrandButtonKind.ghost,
              onPressed: () => _editBudget(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  /// Sets a cap for the viewed month, or edits [existing].
  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref, {
    BudgetProgress? existing,
  }) async {
    final month = ref.read(reportMonthProvider);
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    final controller = TextEditingController(
      text: existing == null ? '' : Fmt.amountInput(existing.budget.amount),
    );
    int? categoryId = existing?.budget.categoryId;

    final saved = await brandSheet<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => SheetScaffold(
          title: existing == null
              ? 'Set budget · ${Fmt.monthYear(month)}'
              : 'Edit budget · ${Fmt.monthYear(month)}',
          actions: [
            BrandButton(
              label: 'Save',
              kind: BrandButtonKind.ghost,
              expand: false,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrandField(
                controller: controller,
                label: 'Monthly amount',
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Applies to'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Pill(
                    label: 'Overall',
                    selected: categoryId == null,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => setState(() => categoryId = null),
                  ),
                  ...categories
                      .where((c) => !c.isIncome)
                      .map(
                        (c) => Pill(
                          label: c.name,
                          icon: AppIcons.category(c.icon),
                          selected: categoryId == c.id,
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () => setState(() => categoryId = c.id),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final amount = double.tryParse(controller.text.trim());
    if (saved != true || amount == null || amount <= 0) return;
    final repo = ref.read(expenseRepositoryProvider);
    // Moving a cap to another category is a different cap, so the old row
    // goes rather than leaving two caps on one month.
    if (existing != null && existing.budget.categoryId != categoryId) {
      await repo.deleteBudget(existing.budget.id);
    }
    await repo.setBudget(amount: amount, categoryId: categoryId, month: month);
  }
}

/// The empty state for a month with no caps yet, offering to copy the last
/// month that had some.
class _EmptyMonth extends ConsumerWidget {
  final VoidCallback onSet;
  const _EmptyMonth({required this.onSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(reportMonthProvider);
    final repo = ref.watch(expenseRepositoryProvider);

    return FutureBuilder<DateTime?>(
      future: repo.latestBudgetMonthBefore(month),
      builder: (context, snapshot) {
        final previous = snapshot.data;
        return Column(
          children: [
            EmptyState(
              icon: AppIcons.pieChart,
              title: 'No budgets for ${Fmt.monthYear(month)}',
              message: 'Cap a category or your whole month.',
              actionLabel: 'Set a budget',
              onAction: onSet,
            ),
            if (previous != null) ...[
              const SizedBox(height: 8),
              BrandButton(
                label: "Copy ${Fmt.monthYear(previous)}'s budgets",
                kind: BrandButtonKind.ghost,
                onPressed: () async {
                  final copied = await repo.copyBudgets(
                    from: previous,
                    to: month,
                  );
                  if (context.mounted && copied == 0) {
                    brandToast(context, 'Nothing to copy.');
                  }
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BudgetRow extends ConsumerWidget {
  final BudgetProgress progress;
  final String currency;
  final VoidCallback onEdit;

  const _BudgetRow({
    required this.progress,
    required this.currency,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = progress;
    final tierColor = switch (p.alertTier) {
      100 => AppColors.dangerLight,
      80 => AppColors.warningLight,
      _ => Color(p.color),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onEdit,
            child: LabeledProgress(
              label: p.label,
              trailing:
                  '${Fmt.money(p.spent, currency)} / ${Fmt.money(p.budget.amount, currency)}',
              value: p.fraction,
              color: tierColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                p.remaining >= 0
                    ? '${Fmt.money(p.remaining, currency)} left'
                    : '${Fmt.money(-p.remaining, currency)} over',
                style: TextStyle(
                  fontSize: 11,
                  color: p.remaining >= 0
                      ? Theme.of(context).colorScheme.outline
                      : AppColors.dangerLight,
                ),
              ),
              const Spacer(),
              CircleIconButton(
                icon: AppIcons.edit,
                tooltip: 'Edit',
                size: 40,
                onPressed: onEdit,
              ),
              CircleIconButton(
                icon: AppIcons.delete,
                tooltip: 'Delete',
                size: 40,
                onPressed: () => ref
                    .read(expenseRepositoryProvider)
                    .deleteBudget(p.budget.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
