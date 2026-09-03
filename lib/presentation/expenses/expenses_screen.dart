import 'package:drift/drift.dart' as drift;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/services/export_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../medicine/camera_scan_screen.dart';
import 'providers/expenses_provider.dart';
import 'repository/expense_repository.dart';
import 'widgets/expense_entry_sheet.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      header: BrandTopBar(
        title: 'Expenses',
        leadingIcon: AppIcons.back,
        actions: [
          CircleIconButton(
            icon: AppIcons.scan,
            tooltip: 'Scan receipt',
            size: 40,
            onPressed: _scanReceipt,
          ),
          CircleIconButton(
            icon: AppIcons.share,
            tooltip: 'Export',
            size: 40,
            onPressed: _showExportSheet,
          ),
        ],
      ),
      floatingAction: BrandFab(
        icon: AppIcons.add,
        tooltip: 'Add transaction',
        onPressed: () => ExpenseEntrySheet.show(context),
      ),
      // BrandTabs owns the strip and the views together, so the strip moves out
      // of the header into the body.
      child: const BrandTabs(
        tabs: {
          'Overview': _OverviewTab(),
          'Reports': _ReportsTab(),
          'Budgets': _BudgetsTab(),
          'Bills': _BillsTab(),
        },
      ),
    );
  }

  Future<void> _scanReceipt() async {
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(
        builder: (_) => const CameraScanScreen(mode: ScanMode.receipt),
      ),
    );
    if (result == null || !mounted) return;
    ExpenseEntrySheet.show(
      context,
      amount: result.amount,
      note: result.merchant,
      receiptPath: result.imagePath,
    );
  }

  void _showExportSheet() {
    final export = ref.read(exportServiceProvider);
    brandSheet(
      context: context,
      builder: (sheetContext) => SheetScaffold(
        title: 'Export',
        child: Column(
          children: [
            BrandTile(
              leading: const AppIcon(AppIcons.spreadsheet),
              title: const Text('Transactions as CSV'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await export.shareFile(await export.expensesCsv());
              },
            ),
            BrandTile(
              leading: const AppIcon(AppIcons.pdf),
              title: const Text('This month as PDF'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _sharePdfReport();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePdfReport() async {
    final export = ref.read(exportServiceProvider);
    final report = await ref.read(monthReportProvider.future);
    final month = ref.read(reportMonthProvider);
    final currency = ref.read(settingsProvider).currencySymbol;
    final categories = await ref.read(categoriesProvider.future);
    final rows = await ref.read(monthTransactionsProvider.future);

    String nameFor(int? id) =>
        categories.where((c) => c.id == id).firstOrNull?.name ??
        'Uncategorised';

    final file = await export.expenseReportPdf(
      title: 'Expense report — ${Fmt.monthYear(month)}',
      currency: currency,
      totalIncome: report.income,
      totalExpense: report.expense,
      byCategory: {
        for (final e in report.byCategory.entries) nameFor(e.key): e.value,
      },
      rows: rows
          .where((r) => r.kind == TxKind.expense || r.kind == TxKind.income)
          .map(
            (r) => (
              date: r.date,
              category: nameFor(r.categoryId),
              note: r.note ?? '',
              amount: r.amount,
              kind: r.kind,
            ),
          )
          .toList(),
    );
    await export.shareFile(file);
  }
}

// --- Overview ---------------------------------------------------------------

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

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

// --- Reports ----------------------------------------------------------------

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(reportMonthProvider);
    final currency = ref.watch(settingsProvider).currencySymbol;
    final reportAsync = ref.watch(monthReportProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final trend = ref.watch(monthlyTrendProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Row(
          children: [
            CircleIconButton(
              icon: AppIcons.chevronLeft,
              size: 40,
              onPressed: () => ref.read(reportMonthProvider.notifier).state =
                  DateTime(month.year, month.month - 1),
            ),
            Expanded(
              child: Text(
                Fmt.monthYear(month),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            CircleIconButton(
              icon: AppIcons.chevronRight,
              size: 40,
              onPressed: () => ref.read(reportMonthProvider.notifier).state =
                  DateTime(month.year, month.month + 1),
            ),
          ],
        ),
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
                        color: AppColors.successLight,
                        label: 'Income',
                        value: Fmt.compactMoney(report.income, currency),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: AppIcons.arrowUp,
                        color: AppColors.dangerLight,
                        label: 'Expense',
                        value: Fmt.compactMoney(report.expense, currency),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
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
                                  color: AppColors.expenseAccent,
                                  width: 10,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                BarChartRodData(
                                  toY: trend[i].income,
                                  color: AppColors.successLight,
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
                    _legend(AppColors.expenseAccent, 'Expense'),
                    const SizedBox(width: 16),
                    _legend(AppColors.successLight, 'Income'),
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

// --- Budgets ----------------------------------------------------------------

class _BudgetsTab extends ConsumerWidget {
  const _BudgetsTab();

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

// --- Bills & subscriptions --------------------------------------------------

class _BillsTab extends ConsumerWidget {
  const _BillsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final bills = ref.watch(recurringProvider);
    final subsTotal = ref.watch(subscriptionTotalProvider).valueOrNull ?? 0;
    final repo = ref.read(expenseRepositoryProvider);

    return Stack(
      children: [
        bills.when(
          loading: () => const Center(child: BrandSpinner()),
          error: (e, _) => Text('$e'),
          data: (rows) => rows.isEmpty
              ? EmptyState(
                  icon: AppIcons.calendarRepeat,
                  title: 'No bills or subscriptions',
                  message:
                      'Track rent, internet, Netflix — anything recurring.',
                  actionLabel: 'Add a bill',
                  onAction: () => _addBill(context, ref),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    if (subsTotal > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: StatTile(
                          icon: AppIcons.subscription,
                          color: AppColors.expenseAccent,
                          label: 'Subscriptions',
                          value: '${Fmt.money(subsTotal, currency)}/month',
                          sublabel:
                              '${Fmt.money(subsTotal * 12, currency)} per year',
                        ),
                      ),
                    ...rows.map((b) {
                      final dueInDays = Fmt.dateOnly(
                        b.nextDueDate,
                      ).difference(Fmt.dateOnly(DateTime.now())).inDays;
                      final overdue = dueInDays < 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TintCard(
                          padding: EdgeInsets.zero,
                          child: BrandTile(
                            leading: AppIcon(
                              b.isSubscription
                                  ? AppIcons.subscription
                                  : AppIcons.bills,
                              color: overdue
                                  ? AppColors.dangerLight
                                  : AppColors.expenseAccent,
                            ),
                            title: Text(
                              b.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${Fmt.money(b.amount, currency)} · ${b.period} · '
                              'due ${Fmt.relativeDay(b.nextDueDate)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: overdue ? AppColors.dangerLight : null,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BrandButton(
                                  label: 'Pay',
                                  kind: BrandButtonKind.ghost,
                                  expand: false,
                                  onPressed: () => repo.payRecurring(b),
                                ),
                                CircleIconButton(
                                  icon: AppIcons.delete,
                                  size: 40,
                                  onPressed: () => repo.deleteRecurring(b.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'bill-fab',
            onPressed: () => _addBill(context, ref),
            backgroundColor: AppColors.expenseAccent,
            foregroundColor: Colors.white,
            child: const AppIcon(AppIcons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _addBill(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final amount = TextEditingController();
    var period = 'monthly';
    var isSubscription = false;
    var due = DateTime.now().add(const Duration(days: 30));
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    int? accountId = accounts.firstOrNull?.id;
    int? categoryId;

    final saved = await brandSheet<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => SheetScaffold(
          title: 'New recurring bill',
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
                controller: name,
                label: 'Name',
                hint: 'Internet',
                autofocus: true,
              ),
              const SizedBox(height: 12),
              BrandField(
                controller: amount,
                label: 'Amount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              BrandSegmented<String>(
                options: const {
                  'weekly': 'Weekly',
                  'monthly': 'Monthly',
                  'yearly': 'Yearly',
                },
                selected: period,
                onSelected: (v) => setState(() => period = v),
              ),
              const SizedBox(height: 8),
              BrandSwitchTile(
                title: 'This is a subscription',
                value: isSubscription,
                onChanged: (v) => setState(() => isSubscription = v),
              ),
              BrandTile(
                leading: const AppIcon(AppIcons.calendar),
                title: const Text('Next due'),
                subtitle: Text(Fmt.dayMonthYear(due)),
                onTap: () async {
                  final picked = await brandDatePicker(
                    context,
                    initial: due,
                    first: DateTime.now(),
                    last: DateTime(2100),
                    title: 'Next due',
                  );
                  if (picked != null) setState(() => due = picked);
                },
              ),
              const SizedBox(height: 8),
              const Text('Account'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: accounts
                    .map(
                      (a) => Pill(
                        label: a.name,
                        selected: accountId == a.id,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () => setState(() => accountId = a.id),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Text('Category'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories
                    .where((c) => !c.isIncome)
                    .map(
                      (c) => Pill(
                        label: c.name,
                        selected: categoryId == c.id,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () => setState(() => categoryId = c.id),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );

    final value = double.tryParse(amount.text.trim());
    if (saved == true && name.text.trim().isNotEmpty && value != null) {
      await ref
          .read(expenseRepositoryProvider)
          .createRecurring(
            RecurringExpensesCompanion.insert(
              name: name.text.trim(),
              amount: value,
              period: drift.Value(period),
              isSubscription: drift.Value(isSubscription),
              nextDueDate: due,
              accountId: drift.Value(accountId),
              categoryId: drift.Value(categoryId),
            ),
          );
    }
  }
}
