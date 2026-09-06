import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/people/person_avatar.dart';
import 'package:mysuite/core/theme/app_palette.dart';
import 'package:mysuite/core/theme/app_theme.dart';

void main() {
  Future<Color> resolve(
    WidgetTester tester,
    AppPalette palette,
    int stored,
  ) async {
    late Color out;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(palette: palette),
        home: Builder(
          builder: (context) {
            out = personColor(context, stored);
            return const SizedBox();
          },
        ),
      ),
    );
    // MaterialApp animates a theme change, so on every palette after the first
    // the builder runs mid-crossfade and reads the previous primary.
    await tester.pumpAndSettle();
    return out;
  }

  testWidgets('a person who never chose a colour follows the palette', (
    tester,
  ) async {
    // The seed is a fixed hex — the brand coral as it was — so every fresh
    // household would otherwise show up in last year's brand under Cobalt.
    for (final p in AppPalette.values) {
      final c = await resolve(tester, p, personColorSeed);
      expect(c, p.spec(Brightness.light).primary, reason: p.name);
    }
  });

  testWidgets('a chosen colour is kept whatever the palette', (tester) async {
    const chosen = 0xFF3BB273;
    for (final p in AppPalette.values) {
      final c = await resolve(tester, p, chosen);
      expect(c, const Color(chosen), reason: p.name);
    }
  });
}
