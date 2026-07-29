import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mysuite/core/theme/app_colors.dart';
import 'package:mysuite/core/theme/app_icons.dart';
import 'package:mysuite/core/theme/app_theme.dart';
import 'package:mysuite/core/widgets/brand.dart';

/// Pumps [child] under a theme built by [AppTheme] so the [BrandColors]
/// extension is registered, the way the real app supplies it.
Future<void> pumpBranded(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  ));
}

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

    final fills = tester
        .widgetList<Material>(find.descendant(
          of: find.byType(TintCard),
          matching: find.byType(Material),
        ))
        .map((m) => m.color)
        .toList();

    expect(fills, contains(AppColors.tintPeach));
    expect(fills, contains(AppColors.tintApricot));
  });

  testWidgets('TintCard outlines itself when the tints are flattened',
      (tester) async {
    await pumpBranded(
      tester,
      const TintCard(child: Text('a')),
      theme: AppTheme.light(highContrast: true),
    );

    final material = tester.widget<Material>(find.descendant(
      of: find.byType(TintCard),
      matching: find.byType(Material),
    ));
    final shape = material.shape! as RoundedRectangleBorder;
    expect(shape.side.style, BorderStyle.solid);
    expect(shape.side.width, greaterThan(0));
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

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: DayStrip(
          selected: selected,
          onSelected: (d) => tapped = d,
        ),
      ),
    ));

    final yesterday = selected.subtract(const Duration(days: 1));
    await tester.tap(find.text(yesterday.day.toString().padLeft(2, '0')));
    await tester.pump();

    expect(tapped, yesterday);
  });

  testWidgets('CurvedNavBar reports the tapped destination', (tester) async {
    var picked = -1;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
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
    ));

    // The bar shows a glyph and a selection dot rather than a label, so the
    // destination is addressed by its tooltip.
    await tester.tap(find.byTooltip('Insights'));
    await tester.pump();

    expect(picked, 2);
  });
}
