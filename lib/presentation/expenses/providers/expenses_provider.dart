import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../repository/expense_repository.dart';

final accountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAccounts();
});

final categoriesProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchCategories();
});

final recentExpensesProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchRecent();
});

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchBudgets();
});

final recurringProvider = StreamProvider<List<RecurringExpense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchRecurring();
});

final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
  return accounts.fold(0.0, (sum, a) => sum + a.balance);
});

/// The month the reports and charts are currently showing.
final reportMonthProvider = StateProvider<DateTime>(
  (ref) => Fmt.startOfMonth(DateTime.now()),
);

final monthTransactionsProvider = StreamProvider<List<Expense>>((ref) {
  final month = ref.watch(reportMonthProvider);
  final end = DateTime(month.year, month.month + 1, 1);
  return ref.watch(expenseRepositoryProvider).watchBetween(month, end);
});

/// Everything the reports tab needs, derived from a single month's rows.
@immutable
class MonthReport {
  final double income;
  final double expense;
  final Map<int?, double> byCategory;
  final Map<DateTime, double> byDay;
  final double previousExpense;

  const MonthReport({
    required this.income,
    required this.expense,
    required this.byCategory,
    required this.byDay,
    required this.previousExpense,
  });

  double get net => income - expense;

  /// Signed change versus last month, as a fraction. Null when there is no
  /// prior month to compare against.
  double? get changeVsPrevious => previousExpense == 0
      ? null
      : (expense - previousExpense) / previousExpense;
}

final monthReportProvider = FutureProvider<MonthReport>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  final month = ref.watch(reportMonthProvider);
  // Depend on the stream so the report refreshes as transactions land.
  final rows = await ref.watch(monthTransactionsProvider.future);

  final byCategory = <int?, double>{};
  final byDay = <DateTime, double>{};
  var income = 0.0;
  var expense = 0.0;

  for (final r in rows) {
    if (r.kind == TxKind.income) {
      income += r.amount;
    } else if (r.kind == TxKind.expense) {
      expense += r.amount;
      byCategory[r.categoryId] = (byCategory[r.categoryId] ?? 0) + r.amount;
      final day = Fmt.dateOnly(r.date);
      byDay[day] = (byDay[day] ?? 0) + r.amount;
    }
  }

  final prevStart = DateTime(month.year, month.month - 1, 1);
  final prev = await repo.totals(prevStart, month);

  return MonthReport(
    income: income,
    expense: expense,
    byCategory: byCategory,
    byDay: byDay,
    previousExpense: prev.expense,
  );
});

/// Income vs expense for the trailing 6 months.
final monthlyTrendProvider =
    FutureProvider<List<({DateTime month, double income, double expense})>>((
      ref,
    ) async {
      // Re-run whenever transactions change.
      ref.watch(recentExpensesProvider);
      return ref.watch(expenseRepositoryProvider).monthlyTrend(6);
    });

/// Budget progress rows for the budgets tab.
@immutable
class BudgetProgress {
  final Budget budget;
  final String label;
  final int color;
  final double spent;

  const BudgetProgress({
    required this.budget,
    required this.label,
    required this.color,
    required this.spent,
  });

  double get fraction => budget.amount <= 0 ? 0 : spent / budget.amount;
  double get remaining => budget.amount - spent;

  /// Alert tier crossed: 0 = none, 50, 80 or 100.
  int get alertTier {
    final pct = fraction * 100;
    if (pct >= 100) return 100;
    if (pct >= 80) return 80;
    if (pct >= 50) return 50;
    return 0;
  }
}

final budgetProgressProvider = FutureProvider<List<BudgetProgress>>((
  ref,
) async {
  final budgets = await ref.watch(budgetsProvider.future);
  final categories = await ref.watch(categoriesProvider.future);
  final report = await ref.watch(monthReportProvider.future);

  return budgets.map((b) {
    if (b.categoryId == null) {
      return BudgetProgress(
        budget: b,
        label: 'Overall',
        color: 0xFF5B7CE0,
        spent: report.expense,
      );
    }
    final cat = categories.where((c) => c.id == b.categoryId).firstOrNull;
    return BudgetProgress(
      budget: b,
      label: cat?.name ?? 'Category',
      color: cat?.color ?? 0xFF6C6C6C,
      spent: report.byCategory[b.categoryId] ?? 0,
    );
  }).toList();
});

/// Total monthly cost of everything flagged as a subscription.
final subscriptionTotalProvider = FutureProvider<double>((ref) async {
  final bills = await ref.watch(recurringProvider.future);
  return bills.where((b) => b.isSubscription).fold<double>(0.0, (sum, b) {
    // Normalise every period to a monthly figure so the audit compares like
    // with like.
    final monthly = switch (b.period) {
      'daily' => b.amount * 30,
      'weekly' => b.amount * 52 / 12,
      'yearly' => b.amount / 12,
      _ => b.amount,
    };
    return sum + monthly;
  });
});
