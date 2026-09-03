import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/people/people_repository.dart';
import '../../../core/utils/formatters.dart';
import '../repository/expense_repository.dart';

/// Accounts money can still move through.
final accountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAccounts();
});

/// Every account, archived ones included, so old rows keep their label.
final allAccountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAllAccounts();
});

final categoriesProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchCategories();
});

final recentExpensesProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchRecent();
});

/// The budgets for the month the reports are showing.
final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  final month = ref.watch(reportMonthProvider);
  return ref.watch(expenseRepositoryProvider).watchBudgets(month);
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
  return _buildReport(repo, month, rows);
});

/// The calendar month's report, for the overview. The reports and budgets
/// tabs step through months; the overview always says what is happening
/// now, so it must not follow them.
final currentMonthReportProvider = FutureProvider<MonthReport>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  // Any new row may fall in this month; re-run when the ledger changes.
  ref.watch(recentExpensesProvider);
  final month = Fmt.startOfMonth(DateTime.now());
  final rows = await repo.between(month, DateTime(month.year, month.month + 1));
  return _buildReport(repo, month, rows);
});

/// The calendar month's overall cap with its spend, or null when none is set.
final currentOverallBudgetProvider = FutureProvider<BudgetProgress?>((
  ref,
) async {
  final repo = ref.watch(expenseRepositoryProvider);
  final report = await ref.watch(currentMonthReportProvider.future);
  final budgets = await repo.budgets(DateTime.now());
  final overall = budgets.where((b) => b.categoryId == null).firstOrNull;
  if (overall == null) return null;
  return BudgetProgress(
    budget: overall,
    label: 'Overall',
    color: 0xFF5B7CE0,
    spent: report.expense,
  );
});

Future<MonthReport> _buildReport(
  ExpenseRepository repo,
  DateTime month,
  List<Expense> rows,
) async {
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
}

/// This month's spending per person, biggest first. Self is included: it is
/// where most of the money goes and the shares only read correctly with it.
final spendByPersonProvider =
    FutureProvider<List<({Person person, double amount})>>((ref) async {
      final rows = await ref.watch(monthTransactionsProvider.future);
      final people = await ref.watch(peopleProvider.future);

      final totals = <int, double>{};
      for (final r in rows.where((r) => r.kind == TxKind.expense)) {
        totals[r.personId] = (totals[r.personId] ?? 0) + r.amount;
      }

      final result = [
        for (final p in people)
          if (totals[p.id] != null) (person: p, amount: totals[p.id]!),
      ]..sort((a, b) => b.amount.compareTo(a.amount));
      return result;
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

/// Loans, unsettled and soonest-due first.
final loansProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchLoans();
});

/// Every repayment row, so outstanding balances derive from one query
/// rather than one per loan.
final loanRepaymentsProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchRepayments();
});

/// A loan with the person on the other side and what is still owed.
@immutable
class LoanRow {
  final Loan loan;
  final Person? person;
  final double repaid;

  const LoanRow({required this.loan, this.person, required this.repaid});

  double get outstanding => loan.principal - repaid;
  bool get isSettled => loan.settledAt != null;

  /// True when they owe me, false when I owe them.
  bool get isLent => loan.direction == LoanDirection.lent;

  /// Days until the loan falls due; negative once overdue.
  int? get dueInDays {
    final due = loan.dueDate;
    if (due == null) return null;
    return Fmt.dateOnly(due).difference(Fmt.dateOnly(DateTime.now())).inDays;
  }
}

final loanRowsProvider = FutureProvider<List<LoanRow>>((ref) async {
  final loans = await ref.watch(loansProvider.future);
  final repayments = await ref.watch(loanRepaymentsProvider.future);
  final people = await ref.watch(peopleProvider.future);

  final repaid = <int, double>{};
  for (final r in repayments) {
    if (r.loanId == null) continue;
    repaid[r.loanId!] = (repaid[r.loanId!] ?? 0) + r.amount;
  }

  return [
    for (final l in loans)
      LoanRow(
        loan: l,
        person: people.where((p) => p.id == l.personId).firstOrNull,
        repaid: repaid[l.id] ?? 0,
      ),
  ];
});

/// What is still owed in each direction, for the Loans tab header.
final loanTotalsProvider = FutureProvider<({double owedToMe, double iOwe})>((
  ref,
) async {
  final rows = await ref.watch(loanRowsProvider.future);
  var owedToMe = 0.0;
  var iOwe = 0.0;
  for (final r in rows.where((r) => !r.isSettled)) {
    if (r.isLent) {
      owedToMe += r.outstanding;
    } else {
      iOwe += r.outstanding;
    }
  }
  return (owedToMe: owedToMe, iOwe: iOwe);
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

/// One category's share of the spending no cap covers.
@immutable
class UncappedSlice {
  /// Null for expenses saved without a category. Those cannot be capped —
  /// there is nothing to attach a budget to — so the row offers to categorise
  /// them instead.
  final int? categoryId;
  final String label;

  /// The category's icon token, for [AppIcons.category]. Null when there is no
  /// category to draw one from.
  final String? icon;
  final int color;
  final double amount;

  const UncappedSlice({
    required this.categoryId,
    required this.label,
    required this.icon,
    required this.color,
    required this.amount,
  });

  bool get isUncategorised => categoryId == null;
}

/// What a month's spending left outside every cap, biggest share first.
@immutable
class UncappedSpending {
  final double total;
  final List<UncappedSlice> slices;

  const UncappedSpending({required this.total, required this.slices});
}

/// The spending no budget covers, or null when the question does not arise.
///
/// Capping two categories and then spending on a third used to leave the
/// budgets tab showing two full bars and nothing else, so a month where the
/// money all escaped looked like a month where none of it moved. This is the
/// remainder that makes the tab add up to what was actually spent.
///
/// Yields null in the two cases where nothing is unbudgeted: an `Overall` cap
/// already promises every taka of the month, and a month whose spending all
/// landed in capped categories has no remainder to report.
final uncappedSpendingProvider = FutureProvider<UncappedSpending?>((ref) async {
  final budgets = await ref.watch(budgetsProvider.future);
  if (budgets.any((b) => b.categoryId == null)) return null;

  final categories = await ref.watch(categoriesProvider.future);
  final report = await ref.watch(monthReportProvider.future);
  final capped = budgets.map((b) => b.categoryId).toSet();

  // `byCategory` counts expenses alone — income and transfers never reach it —
  // so these shares sum to the month's spending and the breakdown adds up to
  // the headline.
  final slices = <UncappedSlice>[];
  for (final entry in report.byCategory.entries) {
    if (capped.contains(entry.key) || entry.value <= 0) continue;
    final cat = categories.where((c) => c.id == entry.key).firstOrNull;
    slices.add(
      UncappedSlice(
        categoryId: entry.key,
        label: entry.key == null ? 'Uncategorised' : (cat?.name ?? 'Category'),
        icon: cat?.icon,
        color: cat?.color ?? 0xFF6C6C6C,
        amount: entry.value,
      ),
    );
  }
  if (slices.isEmpty) return null;

  slices.sort((a, b) => b.amount.compareTo(a.amount));
  return UncappedSpending(
    total: slices.fold(0.0, (sum, s) => sum + s.amount),
    slices: slices,
  );
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
