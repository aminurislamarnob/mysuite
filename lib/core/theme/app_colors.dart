import 'package:flutter/material.dart';

/// The mySuite palette, rebuilt around the coral fitness identity.
///
/// The design leans on one saturated accent (`#F15F43`) sitting on a pure white
/// page, with content grouped into large, barely-there pastel cards rather than
/// outlined boxes. Module colours were re-tinted into the same warm family so
/// six modules still read apart without any of them fighting the brand coral.
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// The single brand accent: FABs, rings, active nav, primary buttons.
  ///
  /// Five percent below the `#FF6547` the design shipped with. The flagship
  /// module carries the brand, so this doubles as the medicine glyph drawn on
  /// a medicine card — and at the original value that pair sat at 2.70:1,
  /// under the 3:1 the contrast gate holds every accent to.
  static const coral = Color(0xFFF15F43);
  static const coralDeep = Color(0xFFE24E32);
  static const coralSoft = Color(0xFFFFAA99);

  /// The near-black that sits on coral. Dark mode always used it; light mode
  /// used white, at 2.91:1 — below AA for the label on a primary button.
  static const onCoral = Color(0xFF3A1206);

  // Light theme
  static const primaryLight = coral;
  static const successLight = Color(0xFF2D8657);
  static const warningLight = Color(0xFFA16B29);
  static const dangerLight = Color(0xFFD34247);
  static const backgroundLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textLight = Color(0xFF0D0D0D);
  static const mutedLight = Color(0xFF6C6C6C);

  /// The faintest grey in the design — chart gridlines, inactive day labels,
  /// progress tracks. Too light for body copy.
  static const hairlineLight = Color(0xFFF1F1F1);

  // Dark theme. The reference file is light-only, so the dark side keeps the
  // same coral on a warm-neutral charcoal rather than inventing a second hue.
  static const primaryDark = Color(0xFFFF7D63);
  static const successDark = Color(0xFF56CE8E);
  static const warningDark = Color(0xFFFFB95C);
  static const dangerDark = Color(0xFFFF6B6F);
  static const backgroundDark = Color(0xFF14100F);
  static const surfaceDark = Color(0xFF1F1A19);
  static const textDark = Color(0xFFF5EFED);
  static const mutedDark = Color(0xFFA79E9B);
  static const hairlineDark = Color(0xFF2C2523);

  // ---------------------------------------------------------------------------
  // Card tints
  // ---------------------------------------------------------------------------

  /// The three pastel card fills lifted straight from the reference screens.
  /// They rotate across a row of cards to keep a grid from looking flat.
  static const tintPeach = Color(0xFFFFF4F2);
  static const tintApricot = Color(0xFFFFF8F2);
  static const tintCream = Color(0xFFFFFEF2);

  static const tints = <Color>[tintPeach, tintApricot, tintCream];

  /// The dark-mode stand-ins for [tints] — the same rotation, but as barely
  /// lifted surfaces so the cards stay readable on charcoal.
  static const tintsDark = <Color>[
    Color(0xFF2A2120),
    Color(0xFF272120),
    Color(0xFF262322),
  ];

  /// Picks a card tint for [index], wrapping around the rotation.
  static Color tint(int index, {Brightness brightness = Brightness.light}) {
    final table = brightness == Brightness.dark ? tintsDark : tints;
    return table[index % table.length];
  }

  // ---------------------------------------------------------------------------
  // Module accents
  // ---------------------------------------------------------------------------

  /// Note and habit share a hue with warning and success, so they share the
  /// value too — one colour that satisfies the stricter of the two bars.
  static const noteAccent = warningLight; // amber
  static const medicineAccent = coral; // the flagship module carries the brand
  static const habitAccent = successLight; // moss green
  static const taskAccent = Color(0xFF5B7CE0); // muted indigo
  static const expenseAccent = Color(0xFF9A6DD7); // warm violet
  static const focusAccent = Color(0xFF349CA5); // teal

  /// The dark-mode twins. Note and habit share a hue with warning and success,
  /// so they reuse those already-tuned darks; the rest apply the same lift the
  /// existing pairs use — saturation x0.85, value x1.10 — which is what keeps a
  /// saturated light accent from vibrating against the charcoal page.
  static const noteAccentDark = warningDark;
  static const medicineAccentDark = primaryDark;
  static const habitAccentDark = successDark;
  static const taskAccentDark = Color(0xFF7E9CF6);
  static const expenseAccentDark = Color(0xFFB58DEC);
  static const focusAccentDark = Color(0xFF59C2CC);

  /// A soft page-card fill derived from any accent, matching the density of the
  /// hand-picked [tints] so a module card sits happily next to a brand card.
  static Color wash(Color accent, {Brightness brightness = Brightness.light}) =>
      brightness == Brightness.dark
      ? Color.alphaBlend(accent.withValues(alpha: 0.14), surfaceDark)
      : Color.alphaBlend(accent.withValues(alpha: 0.07), Colors.white);
}
