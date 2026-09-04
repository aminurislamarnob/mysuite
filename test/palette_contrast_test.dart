import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/theme/app_palette.dart';

/// WCAG 2.1 relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// The WCAG contrast ratio between two opaque colours, 1.0 to 21.0.
double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Lays [fg] over [bg] at [alpha] — the same relationship a card wash has to
/// the page it sits on.
Color _over(Color fg, Color bg, double alpha) =>
    Color.alphaBlend(fg.withValues(alpha: alpha), bg);

void main() {
  // The gate. Adding a palette without filling in a colour, or picking one by
  // eye that happens to fail, breaks here rather than in someone's hands.
  //
  // 4.5:1 is AA for body text; 3:1 is AA for large text and non-text such as
  // an icon or a chart series.
  group('every palette meets WCAG AA', () {
    for (final palette in AppPalette.values) {
      for (final brightness in Brightness.values) {
        final name = '${palette.name} ${brightness.name}';
        final p = palette.spec(brightness);

        test('$name — text pairs clear 4.5:1', () {
          expect(
            contrast(p.onPrimary, p.primary),
            greaterThanOrEqualTo(4.5),
            reason: '$name: a primary button label must be readable',
          );
          expect(
            contrast(p.text, p.background),
            greaterThanOrEqualTo(4.5),
            reason: '$name: body copy on the page',
          );
          expect(
            contrast(p.muted, p.background),
            greaterThanOrEqualTo(4.5),
            reason: '$name: supporting copy is still copy',
          );
        });

        test('$name — status hues clear 4.5:1 on the page', () {
          for (final (label, colour) in [
            ('success', p.success),
            ('warning', p.warning),
            ('danger', p.danger),
          ]) {
            expect(
              contrast(colour, p.background),
              greaterThanOrEqualTo(4.5),
              reason: '$name: $label is used as text, not just as a dot',
            );
          }
        });

        test('$name — module accents clear 3:1 on their own wash', () {
          // A module card fills with a 7% wash of its accent and then draws the
          // accent's icon on top, so this is the pair that actually ships.
          for (final (label, colour) in [
            ('note', p.note),
            ('medicine', p.medicine),
            ('habit', p.habit),
            ('task', p.task),
            ('expense', p.expense),
            ('focus', p.focus),
          ]) {
            expect(
              contrast(colour, _over(colour, p.background, 0.07)),
              greaterThanOrEqualTo(3.0),
              reason: '$name: the $label glyph on a $label card',
            );
          }
        });

        test('$name — the six module accents stay apart', () {
          // Two modules that resolve to the same colour would make the accent
          // system decorative rather than informative.
          final accents = [
            p.note,
            p.medicine,
            p.habit,
            p.task,
            p.expense,
            p.focus,
          ];
          expect(
            accents.toSet(),
            hasLength(accents.length),
            reason: '$name: two modules share an accent',
          );
        });
      }
    }
  });

  test('a palette is persisted by name, and an unknown one falls back', () {
    for (final p in AppPalette.values) {
      expect(AppPaletteX.byName(p.name), p);
    }
    // A build that has never heard of this name must not throw.
    expect(AppPaletteX.byName('chartreuse'), AppPalette.coral);
    expect(AppPaletteX.byName(null), AppPalette.coral);
  });

  test('medicine carries the brand in every palette', () {
    for (final palette in AppPalette.values) {
      for (final brightness in Brightness.values) {
        final p = palette.spec(brightness);
        expect(
          p.medicine,
          p.primary,
          reason: '${palette.name} ${brightness.name}',
        );
      }
    }
  });
}
