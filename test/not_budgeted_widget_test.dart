import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/people/people_repository.dart';
import 'package:mysuite/core/settings/app_settings.dart';
import 'package:mysuite/core/theme/app_colors.dart';
import 'package:mysuite/core/theme/app_forui_theme.dart';
import 'package:mysuite/core/theme/app_icons.dart';
import 'package:mysuite/core/theme/app_theme.dart';
import 'package:mysuite/core/utils/formatters.dart';
import 'package:mysuite/presentation/expenses/providers/expenses_provider.dart';
import 'package:mysuite/presentation/expenses/repository/expense_repository.dart';
import 'package:mysuite/presentation/expenses/widgets/budgets_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The not-budgeted row warns about a month you can still do something about,
/// and reports one you cannot. Only the rendered widget can settle which
/// colour it actually paints, so this drives the real tab.
void main() {
  late AppDatabase db;
  late Directory avatarRoot;
  late ExpenseRepository repo;
  late SharedPreferences prefs;
  late int groceries;

  final thisMonth = Fmt.startOfMonth(DateTime.now());
  final lastMonth = DateTime(thisMonth.year, thisMonth.month - 1, 1);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    avatarRoot = Directory.systemTemp.createTempSync('mysuite-not-budgeted');
    repo = ExpenseRepository(
      db,
      PeopleRepository(db, AvatarStorage(avatarRoot)),
    );
    groceries = (await repo.categories())
        .firstWhere((c) => c.name == 'Groceries')
        .id;
  });

  tearDown(() async {
    await db.close();
    if (avatarRoot.existsSync()) avatarRoot.deleteSync(recursive: true);
  });

  /// Spends in [month] on a category nothing caps, then shows that month.
  Future<void> showMonth(WidgetTester tester, DateTime month) async {
    await repo.addTransaction(
      amount: 2400,
      accountId: (await repo.accounts()).first.id,
      categoryId: groceries,
      date: month,
    );
    // A cap on something else, so the tab renders its list rather than the
    // empty state — the case the row was built for.
    await repo.setBudget(
      amount: 500,
      categoryId: (await repo.categories())
          .firstWhere((c) => c.name == 'Food')
          .id,
      month: month,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          expenseRepositoryProvider.overrideWithValue(repo),
          reportMonthProvider.overrideWith((ref) => month),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: FTheme(
            data: brandForuiTheme(brightness: Brightness.light),
            child: const Scaffold(body: BudgetsTab()),
          ),
        ),
      ),
    );
    // Not `pumpAndSettle`: the tab shows a `BrandSpinner` while its providers
    // resolve, and forui's circular progress never stops animating, so
    // settling never arrives. Pump until the row the test is about is built.
    final row = find.text('Not budgeted');
    for (var i = 0; i < 40 && row.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 25));
    }
  }

  Finder warningIcon() =>
      find.byWidgetPredicate((w) => w is AppIcon && w.icon == AppIcons.warning);

  Color headingColour(WidgetTester tester) =>
      tester.widget<Text>(find.text('Not budgeted')).style!.color!;

  /// Tears the tree down inside the test.
  ///
  /// Disposing the scope cancels drift's query streams, which schedule a
  /// zero-duration timer to do it. Left to the framework's own teardown that
  /// timer is still pending when invariants are checked, and every test fails
  /// on it regardless of its assertions.
  ///
  /// The pump has to carry a duration: a bare `pump()` schedules a frame
  /// without advancing the fake clock, so a zero-duration timer never comes
  /// due and the invariant fails anyway.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  }

  testWidgets('the month you are living in gets the warning', (tester) async {
    await showMonth(tester, thisMonth);

    expect(find.text('Not budgeted'), findsOneWidget);
    expect(warningIcon(), findsOneWidget);
    expect(headingColour(tester), AppColors.warningLight);

    await disposeTree(tester);
  });

  testWidgets('a month that has ended reports without shouting', (
    tester,
  ) async {
    await showMonth(tester, lastMonth);

    // Still there — the figure is worth knowing — but it has dropped the
    // warning icon and the warning colour, because there is nothing left to
    // act on in a closed month.
    expect(find.text('Not budgeted'), findsOneWidget);
    expect(warningIcon(), findsNothing);
    expect(headingColour(tester), isNot(AppColors.warningLight));

    final muted = Theme.of(
      tester.element(find.text('Not budgeted')),
    ).colorScheme.outline;
    expect(headingColour(tester), muted);

    await disposeTree(tester);
  });
}
