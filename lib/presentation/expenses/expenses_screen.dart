import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/export_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../medicine/camera_scan_screen.dart';
import 'categories_screen.dart';
import 'providers/expenses_provider.dart';
import 'repository/expense_repository.dart';
import 'widgets/bills_tab.dart';
import 'widgets/budgets_tab.dart';
import 'widgets/expense_entry_sheet.dart';
import 'widgets/loans_tab.dart';
import 'widgets/overview_tab.dart';
import 'widgets/reports_tab.dart';

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
          BrandMenuButton<String>(
            items: const {'categories': 'Categories'},
            onSelected: (_) => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CategoriesScreen())),
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
          'Overview': OverviewTab(),
          'Reports': ReportsTab(),
          'Budgets': BudgetsTab(),
          'Bills': BillsTab(),
          'Loans': LoansTab(),
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
        child: TileColumn(
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
