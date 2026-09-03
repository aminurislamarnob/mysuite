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

class BudgetsTab extends ConsumerWidget {
  const BudgetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final progress = ref.watch(budgetProgressProvider);

    return Stack(
      children: [
        progress.when(
          loading: () => const Center(child: BrandSpinner()),
          error: (e, _) => Text('$e'),
          data: (rows) => rows.isEmpty
              ? EmptyState(
                  icon: AppIcons.pieChart,
                  title: 'No budgets set',
                  message: 'Cap a category or your whole month.',
                  actionLabel: 'Set a budget',
                  onAction: () => _editBudget(context, ref),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: rows.map((p) {
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
                          LabeledProgress(
                            label: p.label,
                            trailing:
                                '${Fmt.money(p.spent, currency)} / ${Fmt.money(p.budget.amount, currency)}',
                            value: p.fraction,
                            color: tierColor,
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
                                icon: AppIcons.delete,
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
                  }).toList(),
                ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'budget-fab',
            onPressed: () => _editBudget(context, ref),
            backgroundColor: AppColors.expenseAccent,
            foregroundColor: Colors.white,
            child: const AppIcon(AppIcons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _editBudget(BuildContext context, WidgetRef ref) async {
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    final controller = TextEditingController();
    int? categoryId;

    final saved = await brandSheet<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => SheetScaffold(
          title: 'Set budget',
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
    if (saved == true && amount != null && amount > 0) {
      await ref
          .read(expenseRepositoryProvider)
          .setBudget(
            amount: amount,
            categoryId: categoryId,
            month: ref.read(reportMonthProvider),
          );
    }
  }
}
