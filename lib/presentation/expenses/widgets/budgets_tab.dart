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
import 'expense_entry_sheet.dart';
import 'month_stepper.dart';

/// Caps for one month. A month starts empty and is filled either by setting
/// caps or by copying the last month that had any.
class BudgetsTab extends ConsumerWidget {
  const BudgetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final progress = ref.watch(budgetProgressProvider);
    final uncapped = ref.watch(uncappedSpendingProvider).valueOrNull;

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
            _EmptyMonth(
              onSet: () => _editBudget(context, ref),
              uncapped: uncapped,
              currency: currency,
              onCap: (slice) => _cap(context, ref, slice),
            )
          else ...[
            ...rows.map(
              (p) => _BudgetRow(
                progress: p,
                currency: currency,
                onEdit: () => _editBudget(context, ref, existing: p),
              ),
            ),
            // Every taka the caps above do not cover, so a tab of full bars
            // can never stand for a month that quietly emptied.
            if (uncapped != null)
              _NotBudgeted(
                uncapped: uncapped,
                currency: currency,
                onCap: (slice) => _cap(context, ref, slice),
              ),
            // The same pill the empty state offers, so the way to add a cap
            // does not change shape once there is one.
            Center(
              child: BrandButton(
                label: 'Add a budget',
                icon: AppIcons.add,
                expand: false,
                onPressed: () => _editBudget(context, ref),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Acts on one line of the not-budgeted breakdown.
  ///
  /// A category can be capped on the spot. An expense saved without one has
  /// nothing to cap, so that line opens the transactions instead — giving them
  /// a category is the step that has to come first.
  Future<void> _cap(
    BuildContext context,
    WidgetRef ref,
    UncappedSlice slice,
  ) async {
    if (slice.isUncategorised) return _UncategorisedSheet.show(context);
    return _editBudget(
      context,
      ref,
      presetCategoryId: slice.categoryId,
      presetAmount: slice.amount,
    );
  }

  /// Sets a cap for the viewed month, or edits [existing].
  ///
  /// [presetCategoryId] and [presetAmount] arrive from the not-budgeted
  /// breakdown, which knows both the category to cap and what it has already
  /// cost — the obvious opening offer for the cap.
  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref, {
    BudgetProgress? existing,
    int? presetCategoryId,
    double? presetAmount,
  }) async {
    final month = ref.read(reportMonthProvider);
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    final preset = existing?.budget.amount ?? presetAmount;
    final controller = TextEditingController(
      text: preset == null ? '' : Fmt.amountInput(preset),
    );
    int? categoryId = existing?.budget.categoryId ?? presetCategoryId;

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
  final String currency;
  final ValueChanged<UncappedSlice> onCap;

  /// The month's spending, when there is some. With no caps at all every taka
  /// of it is unbudgeted, and someone reading an empty budgets tab has already
  /// spent the money — so this is the moment the figure is worth the most.
  final UncappedSpending? uncapped;

  const _EmptyMonth({
    required this.onSet,
    required this.currency,
    required this.onCap,
    required this.uncapped,
  });

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
            if (uncapped != null) ...[
              const SizedBox(height: 24),
              _NotBudgeted(
                uncapped: uncapped!,
                currency: currency,
                onCap: onCap,
                headline:
                    '${Fmt.money(uncapped!.total, currency)} spent, '
                    'none of it budgeted',
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Everything this month's caps do not cover.
///
/// Deliberately not a progress bar: there is no cap here, so there is no
/// fraction to draw and nothing honest to fill. It reports a figure and the
/// categories behind it, each of which can become a cap.
class _NotBudgeted extends ConsumerStatefulWidget {
  final UncappedSpending uncapped;
  final String currency;
  final ValueChanged<UncappedSlice> onCap;

  /// Replaces the default "Not budgeted" heading on the empty month, where the
  /// figure is the whole of the month's spending rather than a remainder.
  final String? headline;

  const _NotBudgeted({
    required this.uncapped,
    required this.currency,
    required this.onCap,
    this.headline,
  });

  /// How many shares are worth naming before the rest collapses. The biggest
  /// three are where capping actually pays.
  static const _visible = 3;

  @override
  ConsumerState<_NotBudgeted> createState() => _NotBudgetedState();
}

class _NotBudgetedState extends ConsumerState<_NotBudgeted> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final slices = widget.uncapped.slices;
    final muted = Theme.of(context).colorScheme.outline;

    // A month that has ended is a record, not a call to act, so it reports the
    // same figure without the warning colour.
    final month = ref.watch(reportMonthProvider);
    final past = month.isBefore(Fmt.startOfMonth(DateTime.now()));
    final accent = past ? muted : context.brand.warning;

    final shown = _expanded
        ? slices
        : slices.take(_NotBudgeted._visible).toList();
    final hidden = slices.length - shown.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!past) ...[
                AppIcon(AppIcons.warning, size: 16, color: accent),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  widget.headline ?? 'Not budgeted',
                  style: TextStyle(fontWeight: FontWeight.w600, color: accent),
                ),
              ),
              if (widget.headline == null)
                Text(
                  Fmt.money(widget.uncapped.total, widget.currency),
                  style: TextStyle(fontWeight: FontWeight.w700, color: accent),
                ),
            ],
          ),
          const SizedBox(height: 8),
          BrandDivider(),
          const SizedBox(height: 4),
          for (final slice in shown)
            BrandTile(
              dense: true,
              leading: slice.icon == null
                  ? AppIcon(AppIcons.info, color: muted, size: 20)
                  : AppIcon(
                      AppIcons.category(slice.icon!),
                      color: Color(slice.color),
                      size: 20,
                    ),
              title: Text(slice.label),
              trailing: Text(
                Fmt.money(slice.amount, widget.currency),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => widget.onCap(slice),
            ),
          if (hidden > 0 || _expanded)
            Align(
              alignment: Alignment.centerLeft,
              child: BrandButton(
                label: _expanded ? 'Show less' : '+ $hidden more',
                kind: BrandButtonKind.ghost,
                small: true,
                expand: false,
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ),
        ],
      ),
    );
  }
}

/// The month's expenses that were saved without a category.
///
/// They count toward what is not budgeted but cannot be capped, so this offers
/// the step that unblocks that: open one and give it a category.
class _UncategorisedSheet extends ConsumerWidget {
  const _UncategorisedSheet();

  static Future<void> show(BuildContext context) =>
      brandSheet(context: context, builder: (_) => const _UncategorisedSheet());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final rows = ref.watch(monthTransactionsProvider).valueOrNull ?? const [];
    final muted = Theme.of(context).colorScheme.outline;
    final uncategorised = rows
        .where((t) => t.kind == TxKind.expense && t.categoryId == null)
        .toList();

    return SheetScaffold(
      title: 'Uncategorised',
      child: uncategorised.isEmpty
          ? const EmptyState(
              icon: AppIcons.checkCircle,
              title: 'All categorised',
              message: 'Every expense this month has a category.',
            )
          : TileColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final tx in uncategorised)
                  BrandTile(
                    dense: true,
                    leading: AppIcon(AppIcons.info, color: muted, size: 20),
                    title: Text(
                      tx.note?.isNotEmpty == true ? tx.note! : 'Expense',
                    ),
                    subtitle: Text(
                      Fmt.dayMonthYear(tx.date),
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                    trailing: Text(
                      Fmt.money(tx.amount, currency),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      ExpenseEntrySheet.edit(context, tx);
                    },
                  ),
              ],
            ),
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
      100 => context.brand.danger,
      80 => context.brand.warning,
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
                      : context.brand.danger,
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
