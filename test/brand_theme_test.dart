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
import 'package:mysuite/core/theme/app_palette.dart';

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
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light(),
      home: FTheme(
        data: brandForuiTheme(brightness: Brightness.light),
        child: FToaster(
          child: FTooltipGroup(
            child: Scaffold(body: Center(child: child)),
          ),
        ),
      ),
    ),
  );
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

/// The corner radii of every shape a widget subtree paints, in paint order.
List<BorderRadiusGeometry?> radiiOf(WidgetTester tester, Finder of) => tester
    .widgetList<DecoratedBox>(
      find.descendant(of: of, matching: find.byType(DecoratedBox)),
    )
    .map((d) => d.decoration)
    .whereType<ShapeDecoration>()
    .map((d) => d.shape)
    .whereType<RoundedRectangleBorder>()
    .map((b) => b.borderRadius)
    .toList();

void main() {
  group('AppIcon', () {
    testWidgets('holds its size inside a tight box instead of stretching', (
      tester,
    ) async {
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
        tester.getSize(
          find.descendant(
            of: find.byType(AppIcon),
            matching: find.byType(HugeIcon),
          ),
        ),
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

  group('TileGroup', () {
    BorderRadiusGeometry? radiusOf(WidgetTester tester, String label) =>
        radiiOf(
          tester,
          find.ancestor(of: find.text(label), matching: find.byType(BrandTile)),
        ).firstOrNull;

    testWidgets('rounds only the ends, so a run reads as one card', (
      tester,
    ) async {
      await pumpBranded(
        tester,
        const TileGroup(
          children: [
            BrandTile(title: Text('first')),
            BrandTile(title: Text('middle')),
            BrandTile(title: Text('last')),
          ],
        ),
      );

      expect(
        radiusOf(tester, 'first'),
        const BorderRadius.vertical(top: Radius.circular(AppRadii.tile)),
      );
      // The seam between rows is a divider, not a pair of cut corners.
      expect(radiusOf(tester, 'middle'), BorderRadius.zero);
      expect(
        radiusOf(tester, 'last'),
        const BorderRadius.vertical(bottom: Radius.circular(AppRadii.tile)),
      );
    });

    testWidgets('a lone tile still rounds all four corners', (tester) async {
      await pumpBranded(
        tester,
        const TileGroup(children: [BrandTile(title: Text('alone'))]),
      );

      expect(radiusOf(tester, 'alone'), BorderRadius.circular(AppRadii.field));
    });

    testWidgets('a tile outside a group keeps every corner', (tester) async {
      // TileColumn stacks are meant to read as separate cards, so grouping
      // must not reach them.
      await pumpBranded(
        tester,
        const TileColumn(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandTile(title: Text('a')),
            BrandTile(title: Text('b')),
          ],
        ),
      );

      for (final label in ['a', 'b']) {
        expect(
          radiusOf(tester, label),
          BorderRadius.circular(AppRadii.field),
          reason: label,
        );
      }
    });
  });

  group('BrandColors', () {
    test('the chosen palette reaches both halves of the theme', () {
      for (final palette in AppPalette.values) {
        for (final brightness in Brightness.values) {
          final spec = palette.spec(brightness);
          final theme = brightness == Brightness.light
              ? AppTheme.light(palette: palette)
              : AppTheme.dark(palette: palette);
          final brand = theme.extension<BrandColors>()!;
          final where = '${palette.name} ${brightness.name}';

          expect(theme.colorScheme.primary, spec.primary, reason: where);
          expect(theme.colorScheme.onPrimary, spec.onPrimary, reason: where);
          expect(theme.scaffoldBackgroundColor, spec.background, reason: where);
          expect(brand.danger, spec.danger, reason: where);
          expect(brand.task, spec.task, reason: where);
          expect(brand.tints, spec.tints, reason: where);

          // The FAB used to paint its glyph white regardless of what it sat
          // on, which is how coral's label ended up at 2.91:1.
          expect(
            theme.floatingActionButtonTheme.foregroundColor,
            spec.onPrimary,
            reason: where,
          );
        }
      }
    });

    test('only coral pins its tints; the rest derive from the primary', () {
      // Coral keeps the hand-picked peach/apricot/cream rotation the design
      // shipped with. Everything else lays its primary over the page.
      expect(AppPalette.coral.spec(Brightness.light).tints, AppColors.tints);
      for (final p in AppPalette.values.where((p) => p != AppPalette.coral)) {
        final spec = p.spec(Brightness.light);
        expect(spec.tints, hasLength(3));
        expect(spec.tints.toSet(), hasLength(3), reason: '${p.name} tints');
        // Rising density: each fill sits further from the page than the last.
        expect(spec.tints.first, isNot(spec.tints.last), reason: p.name);
      }
    });

    test('dark resolves the dark variant of every slot, not the light one', () {
      // The bug this extension exists to prevent: before the migration, 80
      // unguarded `AppColors.*Light` references outside the theme layer meant
      // dark mode rendered light-mode reds, greens and greys throughout.
      final light = AppTheme.light().extension<BrandColors>()!;
      final dark = AppTheme.dark().extension<BrandColors>()!;

      expect(dark.success, AppColors.successDark);
      expect(dark.warning, AppColors.warningDark);
      expect(dark.danger, AppColors.dangerDark);
      expect(dark.note, AppColors.noteAccentDark);
      expect(dark.medicine, AppColors.medicineAccentDark);
      expect(dark.habit, AppColors.habitAccentDark);
      expect(dark.task, AppColors.taskAccentDark);
      expect(dark.expense, AppColors.expenseAccentDark);
      expect(dark.focus, AppColors.focusAccentDark);

      // And that they are genuinely different from the light ones — a dark
      // variant aliased back to its light twin would pass the checks above.
      for (final pair in [
        (light.success, dark.success),
        (light.warning, dark.warning),
        (light.danger, dark.danger),
        (light.note, dark.note),
        (light.medicine, dark.medicine),
        (light.habit, dark.habit),
        (light.task, dark.task),
        (light.expense, dark.expense),
        (light.focus, dark.focus),
      ]) {
        expect(pair.$2, isNot(pair.$1));
      }
    });

    test('tint wraps around the rotation instead of running off the end', () {
      final brand = _brandOf(Colors.white, tints: AppColors.tints);

      expect(brand.tint(0), AppColors.tintPeach);
      expect(brand.tint(3), brand.tint(0));
      expect(brand.tint(7), brand.tint(1));
    });

    test('lerp interpolates every slot, not just the tints', () {
      final a = _brandOf(Colors.black);
      final b = _brandOf(Colors.white);

      final mid = a.lerp(b, 1.0);

      // Every field, so a slot added later without a matching lerp line fails
      // here rather than silently freezing mid-transition.
      expect(mid.tints, everyElement(Colors.white));
      for (final c in [
        mid.hairline,
        mid.canvas,
        mid.success,
        mid.warning,
        mid.danger,
        mid.note,
        mid.medicine,
        mid.habit,
        mid.task,
        mid.expense,
        mid.focus,
      ]) {
        expect(c, Colors.white);
      }
    });

    // Building a theme resolves the Google font, which needs a live binding —
    // hence testWidgets rather than a plain test for anything touching
    // AppTheme.light() / .dark().
    testWidgets('the light theme registers the coral brand extension', (
      tester,
    ) async {
      final theme = AppTheme.light();
      final brand = theme.extension<BrandColors>();

      expect(brand, isNotNull);
      expect(brand!.tints.first, AppColors.tintPeach);
      expect(theme.colorScheme.primary, AppColors.coral);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
    });
  });

  testWidgets('context.brand falls back when no theme registered it', (
    tester,
  ) async {
    late BrandColors resolved;

    // A plain MaterialApp — no AppTheme, so no extension. Widgets must still
    // build rather than throwing on a null check.
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            resolved = context.brand;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(resolved.tints, isNotEmpty);
    expect(resolved.hairline, AppColors.hairlineLight);
  });

  testWidgets('context.brand picks the dark fallback under a dark theme', (
    tester,
  ) async {
    late BrandColors resolved;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) {
            resolved = context.brand;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved.hairline, AppColors.hairlineDark);
  });

  testWidgets('TintCard rotates its fill through the brand pastels', (
    tester,
  ) async {
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

  testWidgets('TintCard stays borderless — the tint carries the separation', (
    tester,
  ) async {
    await pumpBranded(tester, const TintCard(child: Text('a')));

    final borders = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(TintCard),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.border)
        .whereType<Border>()
        .where((b) => b.top.width > 0)
        .toList();

    expect(borders, isEmpty);
    expect(
      fillsOf(tester, find.byType(TintCard)),
      contains(AppColors.tintPeach),
    );
  });

  testWidgets('ProgressRing renders an overrun in the error colour', (
    tester,
  ) async {
    await pumpBranded(tester, const ProgressRing(value: 1.6, size: 120));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ProgressRing), findsOneWidget);
  });

  testWidgets('SplineChart survives a flat series without dividing by zero', (
    tester,
  ) async {
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
      DayStrip(selected: selected, onSelected: (d) => tapped = d),
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

    await tester.pumpWidget(
      MaterialApp(
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
      ),
    );

    // The bar shows a glyph and a sliding dot rather than a label, so the
    // destination is addressed by the semantics label FBottomNavigationBarItem
    // announces — which also carries its position ("Tab 3 of 4").
    await tester.tap(find.bySemanticsLabel(RegExp('Insights')));
    await tester.pumpAndSettle();

    expect(picked, 2);
  });

  group('BrandScaffold', () {
    testWidgets('provides the Material ancestor FScaffold lacks', (
      tester,
    ) async {
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
      await pumpBranded(tester, BrandScaffold(child: AppIcon(AppIcons.star)));

      // The glyph, not AppIcon's box — the scaffold hands the child a tight
      // constraint, which AppIcon's Center fills while pinning the glyph inside.
      expect(
        tester.getSize(
          find.descendant(
            of: find.byType(AppIcon),
            matching: find.byType(HugeIcon),
          ),
        ),
        const Size(24, 24),
      );
    });
  });

  group('wrappers added during the migration', () {
    testWidgets('BrandCheckbox ticks in the colour it is given', (
      tester,
    ) async {
      // The subtask list ticks in the Tasks accent, not the brand coral, so the
      // checked fill has to be overridable without disturbing forui's disabled
      // and error derivations.
      await pumpBranded(
        tester,
        const BrandCheckbox(
          value: true,
          onChanged: null,
          color: AppColors.taskAccent,
        ),
      );

      final fills = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(BrandCheckbox),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((d) => d.decoration)
          .whereType<ShapeDecoration>()
          .map((d) => d.color);

      expect(fills, contains(AppColors.taskAccent));
    });

    testWidgets('a bare BrandField drops its fill and border', (tester) async {
      // The note editor's title reads as a heading above the Quill body; the
      // usual filled, outlined treatment boxes it in.
      await pumpBranded(
        tester,
        const Column(
          children: [
            BrandField(hint: 'Filled'),
            BrandField(hint: 'Bare', bare: true),
          ],
        ),
      );

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields, hasLength(2));
      expect(fields.first.decoration!.fillColor, AppColors.tintPeach);
      expect(fields.last.decoration!.fillColor, Colors.transparent);
      // forui resolves the border into a WidgetStateInputBorder; resolve it back
      // to the concrete border to confirm the bare field carries none.
      final border = fields.last.decoration!.border;
      final resolved = border is WidgetStateInputBorder
          ? border.resolve(const <WidgetState>{})
          : border;
      expect(resolved, InputBorder.none);
    });

    testWidgets('BrandField surfaces a validation message', (tester) async {
      await pumpBranded(
        tester,
        const BrandField(hint: 'PIN', error: 'Incorrect PIN'),
      );

      expect(find.text('Incorrect PIN'), findsOneWidget);
    });

    testWidgets('BrandSegmented renders one pill per option', (tester) async {
      await pumpBranded(
        tester,
        BrandSegmented<int>(
          options: const {0: 'Build', 1: 'Reduce'},
          icons: const {0: AppIcons.trendUp, 1: AppIcons.trendDown},
          selected: 0,
          onSelected: (_) {},
        ),
      );

      expect(find.byType(Pill), findsNWidgets(2));
      // The icons map is honoured, so the habit control keeps its trend arrows.
      expect(find.byType(AppIcon), findsNWidgets(2));
    });

    testWidgets('BrandChip only offers a remove affordance when it can', (
      tester,
    ) async {
      await pumpBranded(
        tester,
        const Column(
          children: [
            BrandChip(label: '#work'),
            BrandChip(label: '#ideas', onRemove: _noop),
          ],
        ),
      );

      expect(find.byType(CircleIconButton), findsOneWidget);
    });

    testWidgets('TintCard forwards a long press', (tester) async {
      // The habit card opens its editor on long press; before this the screen
      // nested an InkWell inside the card's own tappable.
      var pressed = false;
      await pumpBranded(
        tester,
        TintCard(onLongPress: () => pressed = true, child: const Text('Habit')),
      );

      await tester.longPress(find.text('Habit'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
  });
}

void _noop() {}

/// A [BrandColors] with every slot set to [c], for the structural tests above.
/// Naming each field rather than spreading a default keeps the analyzer honest:
/// a new slot breaks this helper, which is the reminder to cover it.
BrandColors _brandOf(Color c, {List<Color>? tints}) => BrandColors(
  tints: tints ?? [c, c, c],
  hairline: c,
  canvas: c,
  success: c,
  warning: c,
  danger: c,
  note: c,
  medicine: c,
  habit: c,
  task: c,
  expense: c,
  focus: c,
);
