import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mysuite/core/theme/app_colors.dart';
import 'package:mysuite/core/theme/app_forui_theme.dart';
import 'package:mysuite/core/theme/app_theme.dart';

void main() {
  // Resolving the brand font goes through google_fonts, which needs a live
  // binding — hence testWidgets rather than test for anything building a theme.
  group('brandForuiTheme colours', () {
    testWidgets('light maps the coral brand onto forui tokens', (tester) async {
      final colors = brandForuiTheme(brightness: Brightness.light).colors;

      expect(colors.primary, AppColors.coral);
      expect(colors.background, AppColors.backgroundLight);
      expect(colors.foreground, AppColors.textLight);
      expect(colors.border, AppColors.hairlineLight);
      // The rotating pastel fill — forui's `card` is what FCard resolves to.
      expect(colors.card, AppColors.tintPeach);
      expect(colors.mutedForeground, AppColors.mutedLight);
      expect(colors.destructive, AppColors.dangerLight);
      expect(colors.brightness, Brightness.light);
    });

    testWidgets('dark uses the dark brand ramp', (tester) async {
      final colors = brandForuiTheme(brightness: Brightness.dark).colors;

      expect(colors.primary, AppColors.primaryDark);
      expect(colors.background, AppColors.backgroundDark);
      expect(colors.border, AppColors.hairlineDark);
      expect(colors.card, AppColors.tintsDark.first);
      expect(colors.brightness, Brightness.dark);
    });

    testWidgets('secondary and muted are tint surfaces, not the accent',
        (tester) async {
      // shadcn's `secondary`/`muted` are muted backgrounds. Putting an accent
      // there would render every secondary button as a coral slab.
      final colors = brandForuiTheme(brightness: Brightness.light).colors;

      expect(colors.secondary, AppColors.tintApricot);
      expect(colors.muted, AppColors.tintApricot);
      expect(colors.secondary, isNot(AppColors.coralDeep));
    });

    testWidgets('high contrast flattens the card and strengthens the border',
        (tester) async {
      final plain = brandForuiTheme(brightness: Brightness.light);
      final hc =
          brandForuiTheme(brightness: Brightness.light, highContrast: true);

      expect(hc.colors.card, Colors.white);
      expect(hc.colors.border, isNot(plain.colors.border));
      // The outline is what carries separation once the fill is gone.
      expect(hc.style.borderWidth, greaterThan(plain.style.borderWidth));
    });
  });

  group('brandForuiTheme identity', () {
    testWidgets('the same inputs hand back the same instance', (tester) async {
      // `MaterialApp.builder` rebuilds the theme on every settings change, and
      // forui's styles hold `Tween`s, which have no value equality — so a
      // rebuilt theme never compares equal to the last one. Widgets that watch
      // their inherited style then see every rebuild as a real change:
      // `FAccordionItem` resets its reveal animation, which closed the
      // "Lock individual modules" list every time a switch inside it moved.
      final a = brandForuiTheme(brightness: Brightness.light);
      final b = brandForuiTheme(brightness: Brightness.light);

      expect(identical(a, b), isTrue);
      expect(identical(a.accordionStyle, b.accordionStyle), isTrue);
    });

    testWidgets('a changed input still builds a fresh theme', (tester) async {
      final light = brandForuiTheme(brightness: Brightness.light);
      final dark = brandForuiTheme(brightness: Brightness.dark);

      expect(identical(light, dark), isFalse);
      expect(dark.colors.brightness, Brightness.dark);
      // And switching back does not hand out the cached dark one.
      expect(
        brandForuiTheme(brightness: Brightness.light).colors.brightness,
        Brightness.light,
      );
      expect(
        brandForuiTheme(brightness: Brightness.light, compact: true)
            .style
            .sizes
            .tile,
        lessThan(light.style.sizes.tile),
      );
    });
  });

  group('brandForuiTheme dialogs', () {
    testWidgets('sit on the page background, not the card tint', (tester) async {
      // A BrandField fills with the same tint forui's dialogs default to, so on
      // `card` the inputs of a form dialog vanish into their own surface.
      for (final brightness in Brightness.values) {
        final theme = brandForuiTheme(brightness: brightness);
        final decoration = theme.dialogStyle.decoration as ShapeDecoration;

        expect(decoration.color, theme.colors.background);
        expect(decoration.color, isNot(theme.colors.card));
      }
    });

    testWidgets('keep the brand card radius', (tester) async {
      final theme = brandForuiTheme(brightness: Brightness.light);
      final shape =
          (theme.dialogStyle.decoration as ShapeDecoration).shape
              as RoundedSuperellipseBorder;

      expect(
        shape.borderRadius.resolve(TextDirection.ltr).topLeft.x,
        AppRadii.card,
      );
    });

    testWidgets('styling a dialog does not revert the icons to Lucide',
        (tester) async {
      // `FThemeData.copyWith` drops `icons`, so reaching the dialog style
      // through it would silently undo the Hugeicons override. Guarded here
      // because the only symptom is a wrong glyph deep inside forui's chrome.
      final theme = brandForuiTheme(brightness: Brightness.light);

      await tester.pumpWidget(MaterialApp(
        home: FTheme(
          data: theme,
          child: Builder(
            builder: (context) => theme.icons.chevronDown(context),
          ),
        ),
      ));

      expect(find.byType(HugeIcon), findsOneWidget);
    });
  });

  group('brandForuiTheme shape and density', () {
    testWidgets('the radius ramp is pinned to the brand tokens', (tester) async {
      final radii = brandForuiTheme(brightness: Brightness.light).style.borderRadius;

      expect(radii.lg, BorderRadius.circular(AppRadii.field));
      expect(radii.xl, BorderRadius.circular(AppRadii.tile));
      expect(radii.xl2, BorderRadius.circular(AppRadii.card));
      expect(radii.xl3, BorderRadius.circular(AppRadii.sheet));
    });

    testWidgets('the brand is flat — no shadow', (tester) async {
      expect(brandForuiTheme(brightness: Brightness.light).style.shadow, isEmpty);
    });

    testWidgets('compact shrinks rows, standing in for VisualDensity',
        (tester) async {
      final standard = brandForuiTheme(brightness: Brightness.light);
      final compact =
          brandForuiTheme(brightness: Brightness.light, compact: true);

      expect(compact.style.sizes.tile, lessThan(standard.style.sizes.tile));
      expect(
        compact.typography.body.sm.fontSize,
        lessThan(standard.typography.body.sm.fontSize!),
      );
    });
  });

  group('brandForuiTheme typography', () {
    testWidgets('body and display are set in Bricolage Grotesque',
        (tester) async {
      final typography = brandForuiTheme(brightness: Brightness.light).typography;

      expect(typography.body.fontFamily, contains('Bricolage'));
      expect(typography.body.sm.fontFamily, contains('Bricolage'));
      expect(typography.display.xl2.fontFamily, contains('Bricolage'));
    });

    testWidgets('Bengali falls back to Hind Siliguri for Bangla glyphs',
        (tester) async {
      final bn =
          brandForuiTheme(brightness: Brightness.light, locale: 'bn').typography;

      expect(bn.body.fontFamily, contains('HindSiliguri'));
      expect(bn.body.fontFamily, isNot(contains('Bricolage')));
    });

    testWidgets('display carries the heading weight and negative tracking',
        (tester) async {
      final typography = brandForuiTheme(brightness: Brightness.light).typography;

      expect(typography.display.xl2.fontWeight, FontWeight.w700);
      expect(typography.display.xl2.letterSpacing, lessThan(0));
      // Body copy stays at default weight.
      expect(typography.body.sm.fontWeight, isNull);
    });
  });

  group('brandForuiTheme icons', () {
    testWidgets('forui chrome draws Hugeicons, not Lucide', (tester) async {
      // Left at FIcons.lucide(), forui would draw Lucide glyphs inside its own
      // chevrons, clear buttons and loaders — partially undoing the Hugeicons
      // migration in a way nothing else would catch.
      final theme = brandForuiTheme(brightness: Brightness.light);

      await tester.pumpWidget(MaterialApp(
        home: FTheme(
          data: theme,
          child: Builder(
            builder: (context) => theme.icons.chevronRight(context),
          ),
        ),
      ));

      expect(find.byType(HugeIcon), findsOneWidget);
    });

    testWidgets('icon tokens forward their semantics label', (tester) async {
      final theme = brandForuiTheme(brightness: Brightness.light);

      await tester.pumpWidget(MaterialApp(
        home: FTheme(
          data: theme,
          child: Builder(
            builder: (context) =>
                theme.icons.check(context, semanticsLabel: 'Done'),
          ),
        ),
      ));

      expect(find.bySemanticsLabel('Done'), findsOneWidget);
    });
  });

  testWidgets('the brand extension is reachable from the forui theme',
      (tester) async {
    // Registered on both themes from the same BrandTokens instance, so
    // context.brand and forui-side lookups cannot disagree.
    final theme = brandForuiTheme(brightness: Brightness.light);

    expect(theme.extension<BrandColors>().tints.first, AppColors.tintPeach);
    expect(theme.colors.extension<BrandColors>().hairline, AppColors.hairlineLight);
  });

  group('tabs', () {
    test('the selected tab is a coral pill with a contrasting label', () {
      // The tab strip borrows Pill's language: a solid coral stadium behind the
      // selected label, muted labels elsewhere, and no track.
      final style = brandForuiTheme(brightness: Brightness.light).tabsStyle;

      final indicator = style.indicatorDecoration as ShapeDecoration;
      expect(indicator.color, AppColors.coral);
      expect(indicator.shape, isA<StadiumBorder>());

      final selected =
          style.labelTextStyle.resolve({FTabVariant.selected}).color;
      final unselected = style.labelTextStyle.resolve(const {}).color;

      // The bug this guards: TabBarThemeData.labelColor takes precedence over
      // labelStyle.color inside Material's TabBar, which FTabs builds on. A
      // stray Material tabBarTheme painted the label coral on the coral pill,
      // making the selected tab's text invisible.
      expect(selected, isNot(indicator.color));
      expect(unselected, isNot(indicator.color));
      expect(selected, Colors.white);
    });

    test('the strip has no track of its own', () {
      // Full-bleed only works because the track is gone; a filled track would
      // show its clipped corners at the screen edges.
      final decoration = brandForuiTheme(brightness: Brightness.light)
          .tabsStyle
          .decoration as BoxDecoration;

      expect(decoration.color, isNull);
      expect(decoration.border, isNull);
    });

    test('no Material tabBarTheme can override the forui tab colours', () {
      // FTabs builds on Material's TabBar, so any tabBarTheme leaks into it.
      expect(AppTheme.light().tabBarTheme, const TabBarThemeData());
      expect(AppTheme.dark().tabBarTheme, const TabBarThemeData());
    });
  });
}
