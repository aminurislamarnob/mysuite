import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mysuite/core/settings/app_settings.dart';
import 'package:mysuite/core/theme/app_forui_theme.dart';
import 'package:mysuite/core/theme/app_theme.dart';
import 'package:mysuite/presentation/settings/how_to_content.dart';
import 'package:mysuite/presentation/settings/how_to_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The guides are content, so most of what can go wrong is a module without a
/// guide or a guide with nothing in it. The screen tests cover the two things
/// the page does beyond showing text: opening a card, and offering to switch
/// a module back on.
void main() {
  group('howToGuides', () {
    test('every module has exactly one guide, keyed by its name', () {
      for (final m in AppModule.values) {
        final guides = howToGuides.where((g) => g.module == m).toList();
        expect(guides, hasLength(1), reason: '${m.name} needs one guide');
        expect(guides.single.id, m.name);
      }
    });

    test('ids are unique and every guide has steps', () {
      final ids = howToGuides.map((g) => g.id).toSet();
      expect(ids, hasLength(howToGuides.length));
      for (final g in howToGuides) {
        expect(g.steps, isNotEmpty, reason: '${g.id} has no steps');
        expect(g.steps.length, lessThanOrEqualTo(6), reason: '${g.id} is long');
        for (final s in g.steps) {
          expect(s.action.trim(), isNotEmpty);
          expect(s.detail.trim(), isNotEmpty);
        }
      }
    });

    test('the quick start comes first', () {
      expect(howToGuides.first.module, isNull);
      expect(howToGuides.first.id, 'start');
    });
  });

  group('HowToScreen', () {
    late SharedPreferences prefs;

    Future<ProviderContainer> pump(
      WidgetTester tester, {
      String? initialGuide,
      Map<String, Object> initial = const {},
      double textScale = 1.0,
    }) async {
      SharedPreferences.setMockInitialValues(initial);
      prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: FTheme(
              data: brandForuiTheme(brightness: Brightness.light),
              child: FToaster(
                child: FTooltipGroup(
                  child: Builder(
                    builder: (context) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.linear(textScale)),
                      child: HowToScreen(initialGuide: initialGuide),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    Finder card(String id) => find.byKey(Key('howto-card-$id'));

    testWidgets('shows a card per guide with only the quick start open', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pump(tester);

      for (final g in howToGuides) {
        expect(card(g.id), findsOneWidget);
      }
      expect(find.text(howToGuides.first.steps.first.action), findsOneWidget);
      final tasks = howToGuides.singleWhere((g) => g.id == 'tasks');
      expect(find.text(tasks.steps.first.action), findsNothing);
    });

    testWidgets('tapping a header opens that guide', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pump(tester);

      final expenses = howToGuides.singleWhere((g) => g.id == 'expenses');
      final header = find.descendant(
        of: card('expenses'),
        matching: find.text(expenses.title),
      );
      await tester.tap(header);
      await tester.pumpAndSettle();

      expect(find.text(expenses.steps.first.action), findsOneWidget);
      expect(find.text('Open Expenses'), findsOneWidget);
    });

    testWidgets('the jump strip opens a guide too', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pump(tester);

      final focus = howToGuides.singleWhere((g) => g.id == 'focus');
      expect(find.text(focus.steps.first.action), findsNothing);

      // The strip scrolls sideways and Focus sits past the right edge.
      final pill = find.byKey(const Key('howto-jump-focus'));
      await tester.ensureVisible(pill);
      await tester.pumpAndSettle();
      await tester.tap(pill);
      await tester.pumpAndSettle();

      expect(find.text(focus.steps.first.action), findsOneWidget);
    });

    testWidgets('initialGuide arrives open', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pump(tester, initialGuide: 'habits');

      final habits = howToGuides.singleWhere((g) => g.id == 'habits');
      expect(find.text(habits.steps.first.action), findsOneWidget);
    });

    testWidgets('a switched-off module can be turned on from its guide', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = await pump(
        tester,
        initialGuide: 'focus',
        initial: {
          'enabled_modules': [
            'notes',
            'medicine',
            'habits',
            'tasks',
            'expenses',
          ],
        },
      );

      expect(find.text('Off'), findsOneWidget);
      expect(find.text('Turn on'), findsOneWidget);
      expect(find.text('Open Focus'), findsNothing);

      await tester.tap(find.text('Turn on'));
      await tester.pumpAndSettle();

      expect(
        container.read(settingsProvider).isEnabled(AppModule.focus),
        isTrue,
      );
      expect(find.text('Turn on'), findsNothing);
      expect(find.text('Open Focus'), findsOneWidget);
    });

    testWidgets('every guide lays out on a narrow phone at the largest text', (
      tester,
    ) async {
      // 320 is the narrowest phone the app is likely to meet and 1.6 is the
      // top of the Settings text-size slider. A row that cannot wrap shows
      // up here as a RenderFlex overflow, which the framework reports as an
      // exception.
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pump(tester, textScale: 1.6);

      for (final g in howToGuides.skip(1)) {
        final header = find.descendant(
          of: card(g.id),
          matching: find.text(g.title),
        );
        await tester.ensureVisible(header);
        await tester.pumpAndSettle();
        await tester.tap(header);
        await tester.pumpAndSettle();
      }

      for (final g in howToGuides) {
        for (final step in g.steps) {
          expect(find.text(step.action), findsOneWidget);
        }
      }
      expect(tester.takeException(), isNull);
    });
  });
}
