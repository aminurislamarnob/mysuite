import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mysuite/core/theme/app_colors.dart';
import 'package:mysuite/core/theme/app_forui_theme.dart';
import 'package:mysuite/core/theme/app_icons.dart';
import 'package:mysuite/core/theme/app_theme.dart';
import 'package:mysuite/core/widgets/brand.dart';
import 'package:mysuite/core/widgets/common.dart';

/// Pumps [child] the way the real app does: a Material theme carrying the
/// [BrandColors] extension, with the forui theme layered underneath it.
///
/// [FTheme] is not optional. forui's [FTappable] — which every tappable brand
/// widget now sits on — reads `FAccessibilityScope` from it and throws without
/// one. [FToaster] and [FTooltipGroup] are hosted for the same reason: they are
/// the ancestors `showFToast` and [FTooltip] require, and `main.dart` installs
/// all three above the router.
Future<void> pumpBranded(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  bool highContrast = false,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light(highContrast: highContrast),
    home: FTheme(
      data: brandForuiTheme(
        brightness: Brightness.light,
        highContrast: highContrast,
      ),
      child: FToaster(
        child: FTooltipGroup(
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    ),
  ));
}

/// The [BoxDecoration] fills painted inside [of], outermost first.
///
/// [FCard] paints through a [DecoratedBox] rather than a Material `Material`, so
/// this is how a brand surface's fill is inspected now.
List<Color?> fillsOf(WidgetTester tester, Finder of) => tester
    .widgetList<DecoratedBox>(
      find.descendant(of: of, matching: find.byType(DecoratedBox)),
    )
    .map((d) => d.decoration)
    .whereType<BoxDecoration>()
    .map((d) => d.color)
    .toList();

void main() {
  group('AppIcon', () {
    testWidgets('holds its size inside a tight box instead of stretching',
        (tester) async {
      // CircleIconButton sizes a 44px SizedBox and asks for a ~20px glyph. An
      // SVG will happily fill a tight constraint, which is what made the top
      // bar glyphs overflow their circle.
      await pumpBranded(
        tester,
        SizedBox(
          width: 44,
          height: 44,
          child: AppIcon(AppIcons.barChart, size: 20),
        ),
      );

      expect(tester.getSize(find.byType(AppIcon)), const Size(44, 44));
      expect(
        tester.getSize(find.descendant(
          of: find.byType(AppIcon),
          matching: find.byType(HugeIcon),
        )),
        const Size(20, 20),
      );
    });

    testWidgets('falls back to the ambient IconTheme size', (tester) async {
      await pumpBranded(
        tester,
        IconTheme(
          data: const IconThemeData(size: 30),
          child: AppIcon(AppIcons.star),
        ),
      );

      expect(tester.getSize(find.byType(AppIcon)), const Size(30, 30));
    });
  });

  group('BrandColors', () {
    test('tint wraps around the rotation instead of running off the end', () {
      const brand = BrandColors(
        tints: AppColors.tints,
        hairline: AppColors.hairlineLight,
        canvas: Colors.white,
      );

      expect(brand.tint(0), AppColors.tintPeach);
      expect(brand.tint(3), brand.tint(0));
      expect(brand.tint(7), brand.tint(1));
    });

    test('lerp interpolates every tint, not just the first', () {
      const a = BrandColors(
        tints: [Colors.black, Colors.black, Colors.black],
        hairline: Colors.black,
        canvas: Colors.black,
      );
      const b = BrandColors(
        tints: [Colors.white, Colors.white, Colors.white],
        hairline: Colors.white,
        canvas: Colors.white,
      );

      final mid = a.lerp(b, 1.0);
      expect(mid.tints, everyElement(Colors.white));
      expect(mid.hairline, Colors.white);
    });

    // Building a theme resolves the Google font, which needs a live binding —
    // hence testWidgets rather than a plain test for anything touching
    // AppTheme.light() / .dark().
    testWidgets('the light theme registers the coral brand extension',
        (tester) async {
      final theme = AppTheme.light();
      final brand = theme.extension<BrandColors>();

      expect(brand, isNotNull);
      expect(brand!.tints.first, AppColors.tintPeach);
      expect(theme.colorScheme.primary, AppColors.coral);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
    });

    testWidgets('high contrast flattens the tints so the outline can take over',
        (tester) async {
      final brand =
          AppTheme.light(highContrast: true).extension<BrandColors>()!;
      // All three collapse to one colour; TintCard keys its border off that.
      expect(brand.tints.toSet(), hasLength(1));
    });
  });

  testWidgets('context.brand falls back when no theme registered it',
      (tester) async {
    late BrandColors resolved;

    // A plain MaterialApp — no AppTheme, so no extension. Widgets must still
    // build rather than throwing on a null check.
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        resolved = context.brand;
        return const SizedBox();
      }),
    ));

    expect(tester.takeException(), isNull);
    expect(resolved.tints, isNotEmpty);
    expect(resolved.hairline, AppColors.hairlineLight);
  });

  testWidgets('context.brand picks the dark fallback under a dark theme',
      (tester) async {
    late BrandColors resolved;

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: Builder(builder: (context) {
        resolved = context.brand;
        return const SizedBox();
      }),
    ));

    expect(resolved.hairline, AppColors.hairlineDark);
  });

  testWidgets('TintCard rotates its fill through the brand pastels',
      (tester) async {
    await pumpBranded(
      tester,
      const Column(
        children: [
          TintCard(tintIndex: 0, child: Text('a')),
          TintCard(tintIndex: 1, child: Text('b')),
        ],
      ),
    );

    final fills = fillsOf(tester, find.byType(TintCard));

    expect(fills, contains(AppColors.tintPeach));
    expect(fills, contains(AppColors.tintApricot));
  });

  testWidgets('TintCard outlines itself when the tints are flattened',
      (tester) async {
    await pumpBranded(
      tester,
      const TintCard(child: Text('a')),
      highContrast: true,
    );

    final borders = tester
        .widgetList<DecoratedBox>(find.descendant(
          of: find.byType(TintCard),
          matching: find.byType(DecoratedBox),
        ))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.border)
        .whereType<Border>()
        .where((b) => b.top.width > 0)
        .toList();

    // The pastel fill is gone at high contrast, so a real outline has to appear.
    expect(borders, isNotEmpty);
    expect(borders.first.top.style, BorderStyle.solid);
    expect(fillsOf(tester, find.byType(TintCard)), contains(Colors.white));
  });

  testWidgets('ProgressRing renders an overrun in the error colour',
      (tester) async {
    await pumpBranded(tester, const ProgressRing(value: 1.6, size: 120));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ProgressRing), findsOneWidget);
  });

  testWidgets('SplineChart survives a flat series without dividing by zero',
      (tester) async {
    await pumpBranded(
      tester,
      const SizedBox(
        width: 300,
        child: SplineChart(
          values: [4, 4, 4, 4],
          labels: ['Mon', 'Tue', 'Wed', 'Thu'],
          color: AppColors.coral,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('SplineChart handles a single sample', (tester) async {
    await pumpBranded(
      tester,
      const SizedBox(
        width: 300,
        child: SplineChart(
          values: [7],
          labels: ['Mon'],
          color: AppColors.coral,
          highlight: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('DayStrip selects the tapped day', (tester) async {
    final today = DateTime.now();
    var selected = DateTime(today.year, today.month, today.day);
    late DateTime tapped;

    await pumpBranded(
      tester,
      DayStrip(
        selected: selected,
        onSelected: (d) => tapped = d,
      ),
    );

    final yesterday = selected.subtract(const Duration(days: 1));
    await tester.tap(find.text(yesterday.day.toString().padLeft(2, '0')));
    // FTappable schedules a press-state timer; settle it before the tree is torn
    // down or the binding reports a pending timer.
    await tester.pumpAndSettle();

    expect(tapped, yesterday);
  });

  testWidgets('CurvedNavBar reports the tapped destination', (tester) async {
    var picked = -1;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: FTheme(
        data: brandForuiTheme(brightness: Brightness.light),
        child: FToaster(
          child: FTooltipGroup(
            child: Scaffold(
              bottomNavigationBar: CurvedNavBar(
                currentIndex: 0,
                onSelected: (i) => picked = i,
                centerAction: const SizedBox(width: 58, height: 58),
                items: const [
                  CurvedNavItem(icon: AppIcons.dashboard, label: 'Today'),
                  CurvedNavItem(icon: AppIcons.modules, label: 'Modules'),
                  CurvedNavItem(icon: AppIcons.insights, label: 'Insights'),
                  CurvedNavItem(icon: AppIcons.settings, label: 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    ));

    // The bar shows a glyph and a sliding dot rather than a label, so the
    // destination is addressed by the semantics label FBottomNavigationBarItem
    // announces — which also carries its position ("Tab 3 of 4").
    await tester.tap(find.bySemanticsLabel(RegExp('Insights')));
    await tester.pumpAndSettle();

    expect(picked, 2);
  });

  group('BrandScaffold', () {
    testWidgets('provides the Material ancestor FScaffold lacks', (tester) async {
      // flutter_quill, flutter_slidable, Dismissible, PopupMenuButton and
      // DataTable all assert on an ancestor Material and throw "No Material
      // widget found" without one. FScaffold does not supply it, so this is the
      // guard for that whole failure class.
      await pumpBranded(
        tester,
        BrandScaffold(
          child: InkWell(onTap: () {}, child: const Text('needs material')),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('needs material'), findsOneWidget);
    });

    testWidgets('restores the 24px content icon size', (tester) async {
      // FScaffold installs an IconTheme from FStyle.iconStyle, which is sized for
      // forui's own chevrons and loaders (20). Content glyphs expect Material's
      // 24, so leaving it would silently shrink icons on every page.
      await pumpBranded(
        tester,
        BrandScaffold(child: AppIcon(AppIcons.star)),
      );

      // The glyph, not AppIcon's box — the scaffold hands the child a tight
      // constraint, which AppIcon's Center fills while pinning the glyph inside.
      expect(
        tester.getSize(find.descendant(
          of: find.byType(AppIcon),
          matching: find.byType(HugeIcon),
        )),
        const Size(24, 24),
      );
    });
  });
}
