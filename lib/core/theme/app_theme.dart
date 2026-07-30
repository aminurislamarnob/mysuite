import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Shape tokens for the coral rebrand. The reference design groups content into
/// large, softly rounded cards and uses full pills for anything tappable.
class AppRadii {
  const AppRadii._();

  /// Hero banners and the big section cards.
  static const card = 24.0;

  /// Stat tiles, list rows and other nested surfaces.
  static const tile = 20.0;

  /// Inputs, small chips and icon buttons.
  static const field = 16.0;

  /// Bottom sheets.
  static const sheet = 28.0;

  static const cardShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(card)));
  static const tileShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(tile)));
}

/// Extra brand colours the [ColorScheme] has no slot for, hung off the theme so
/// widgets can read them without importing [AppColors] and hardcoding a mode.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  /// The rotating pastel card fills.
  final List<Color> tints;

  /// The faintest grey: chart gridlines, progress tracks, dividers.
  final Color hairline;

  /// The page background behind the cards.
  final Color canvas;

  const BrandColors({
    required this.tints,
    required this.hairline,
    required this.canvas,
  });

  /// The pastel fill for the card at [index] in a row or grid.
  Color tint(int index) => tints[index % tints.length];

  /// A reasonable stand-in derived from any [ThemeData], for the case where a
  /// widget is built under a theme that never registered the extension.
  factory BrandColors.fallback(ThemeData theme) {
    final dark = theme.brightness == Brightness.dark;
    final tints = dark ? AppColors.tintsDark : AppColors.tints;
    return BrandColors(
      tints: tints,
      hairline: dark ? AppColors.hairlineDark : AppColors.hairlineLight,
      canvas: theme.scaffoldBackgroundColor,
    );
  }

  @override
  BrandColors copyWith({
    List<Color>? tints,
    Color? hairline,
    Color? canvas,
  }) {
    return BrandColors(
      tints: tints ?? this.tints,
      hairline: hairline ?? this.hairline,
      canvas: canvas ?? this.canvas,
    );
  }

  @override
  BrandColors lerp(BrandColors? other, double t) {
    if (other == null) return this;
    return BrandColors(
      tints: [
        for (var i = 0; i < tints.length; i++)
          Color.lerp(tints[i], other.tints[i], t)!,
      ],
      hairline: Color.lerp(hairline, other.hairline, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
    );
  }
}

/// The resolved brand palette for one appearance.
///
/// Both the Material [ThemeData] and the forui `FThemeData` are built from an
/// instance of this, so a colour can only be changed in one place and the two
/// component systems cannot drift apart.
@immutable
class BrandTokens {
  final Brightness brightness;
  final bool highContrast;
  final bool compact;
  final String locale;

  /// Body copy and headings.
  final Color text;

  /// Supporting copy, placeholder text, unselected icons.
  final Color muted;

  /// The page background.
  final Color background;

  /// Raised surfaces — dialogs, sheets, popovers.
  final Color surface;

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color error;

  /// Tints, hairline and canvas — the values with no [ColorScheme] slot.
  final BrandColors brand;

  /// Cards are normally borderless; the pastel fill separates them. At high
  /// contrast the fill disappears, so a real outline takes over.
  final BorderSide cardBorder;

  const BrandTokens({
    required this.brightness,
    required this.highContrast,
    required this.compact,
    required this.locale,
    required this.text,
    required this.muted,
    required this.background,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.error,
    required this.brand,
    required this.cardBorder,
  });

  bool get isDark => brightness == Brightness.dark;

  /// The font family for [locale]. Bangla glyphs are absent from Bricolage
  /// Grotesque, so Bengali falls back to Hind Siliguri.
  String get fontFamily =>
      (locale == 'bn' ? GoogleFonts.hindSiliguri() : GoogleFonts.bricolageGrotesque())
          .fontFamily!;
}

extension BrandTheme on BuildContext {
  /// The brand palette for the nearest [Theme].
  ///
  /// Falls back to a scheme-derived approximation rather than throwing, so a
  /// widget still renders under a plain [MaterialApp] — Flutter's own default
  /// themes, `showDialog` overrides and widget tests all supply one.
  BrandColors get brand {
    final theme = Theme.of(this);
    return theme.extension<BrandColors>() ?? BrandColors.fallback(theme);
  }

  /// The muted body-copy grey. Shorthand for the most-repeated lookup in the
  /// codebase.
  Color get muted => Theme.of(this).colorScheme.outline;
}

class AppTheme {
  const AppTheme._();

  /// Bangla glyphs are absent from Bricolage Grotesque, so the Bengali locale
  /// swaps in Hind Siliguri. Both are served through google_fonts.
  static TextTheme _textTheme(TextTheme base, Color body, String locale) {
    final themed = locale == 'bn'
        ? GoogleFonts.hindSiliguriTextTheme(base)
        : GoogleFonts.bricolageGrotesqueTextTheme(base);
    return themed.apply(bodyColor: body, displayColor: body).copyWith(
          // The design sets headings in heavy, tight-tracked weights and lets
          // the muted grey carry the supporting copy.
          displayLarge: themed.displayLarge?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -1, color: body),
          displayMedium: themed.displayMedium?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -0.8, color: body),
          displaySmall: themed.displaySmall?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -0.6, color: body),
          headlineMedium: themed.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -0.5, color: body),
          headlineSmall: themed.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -0.4, color: body),
          titleLarge: themed.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: body),
          titleMedium: themed.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: body),
          titleSmall: themed.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600, color: body),
        );
  }

  /// Resolves the brand palette for one appearance.
  ///
  /// This is the single place a brand colour is decided. `light()`, `dark()` and
  /// `brandForuiTheme()` all read from it.
  static BrandTokens tokens({
    required Brightness brightness,
    bool highContrast = false,
    bool compact = false,
    String locale = 'en',
  }) {
    final dark = brightness == Brightness.dark;

    final text = highContrast
        ? (dark ? Colors.white : Colors.black)
        : (dark ? AppColors.textDark : AppColors.textLight);
    final muted = highContrast
        ? (dark ? const Color(0xFFD8D0CE) : const Color(0xFF3D3D3D))
        : (dark ? AppColors.mutedDark : AppColors.mutedLight);

    return BrandTokens(
      brightness: brightness,
      highContrast: highContrast,
      compact: compact,
      locale: locale,
      text: text,
      muted: muted,
      background: highContrast
          ? (dark ? Colors.black : Colors.white)
          : (dark ? AppColors.backgroundDark : AppColors.backgroundLight),
      surface: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
      primary: dark ? AppColors.primaryDark : AppColors.primaryLight,
      onPrimary: dark ? const Color(0xFF3A1206) : Colors.white,
      secondary: dark ? AppColors.coralSoft : AppColors.coralDeep,
      error: dark ? AppColors.dangerDark : AppColors.dangerLight,
      brand: BrandColors(
        tints: highContrast
            // Pastel fills wash out at high contrast, so cards fall back to
            // flat and lean on the stronger outline instead.
            ? (dark
                ? const [Colors.black, Colors.black, Colors.black]
                : const [Colors.white, Colors.white, Colors.white])
            : (dark ? AppColors.tintsDark : AppColors.tints),
        hairline: highContrast
            ? (dark ? const Color(0xFF6E6E6E) : const Color(0xFF9A9A9A))
            : (dark ? AppColors.hairlineDark : AppColors.hairlineLight),
        canvas: dark
            ? (highContrast ? Colors.black : AppColors.backgroundDark)
            : Colors.white,
      ),
      cardBorder:
          highContrast ? BorderSide(color: text, width: 1.2) : BorderSide.none,
    );
  }

  static ThemeData light({
    bool highContrast = false,
    bool compact = false,
    String locale = 'en',
  }) {
    final t = tokens(
      brightness: Brightness.light,
      highContrast: highContrast,
      compact: compact,
      locale: locale,
    );
    return _build(
      t,
      ColorScheme.light(
        primary: t.primary,
        onPrimary: t.onPrimary,
        secondary: t.secondary,
        surface: t.surface,
        error: t.error,
        onSurface: t.text,
        outline: t.muted,
        // `surfaceContainer` is the pastel fill Material picks for grouped
        // content, so pointing it at the peach tint brands stock widgets too.
        surfaceContainer: AppColors.tintPeach,
        surfaceContainerHighest: AppColors.tintApricot,
      ),
    );
  }

  static ThemeData dark({
    bool highContrast = false,
    bool compact = false,
    String locale = 'en',
  }) {
    final t = tokens(
      brightness: Brightness.dark,
      highContrast: highContrast,
      compact: compact,
      locale: locale,
    );
    return _build(
      t,
      ColorScheme.dark(
        primary: t.primary,
        onPrimary: t.onPrimary,
        secondary: t.secondary,
        surface: t.surface,
        error: t.error,
        onSurface: t.text,
        outline: t.muted,
        surfaceContainer: AppColors.tintsDark.first,
        surfaceContainerHighest: AppColors.tintsDark.last,
      ),
    );
  }

  static ThemeData _build(BrandTokens t, ColorScheme scheme) {
    final brightness = t.brightness;
    final background = t.background;
    final surface = t.surface;
    final text = t.text;
    final muted = t.muted;
    final primary = t.primary;
    final onPrimary = t.onPrimary;
    final brand = t.brand;
    final compact = t.compact;
    final highContrast = t.highContrast;
    final locale = t.locale;
    final cardBorder = t.cardBorder;

    final base =
        brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();
    final textTheme = _textTheme(base.textTheme, text, locale);

    OutlineInputBorder field(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      textTheme: textTheme,
      extensions: [brand],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: highContrast ? muted : brand.hairline,
        space: 1,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: textTheme.titleMedium?.copyWith(fontSize: 17),
      ),
      cardTheme: CardThemeData(
        color: brand.tints.first,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.tile),
          side: cardBorder,
        ),
        margin: EdgeInsets.zero,
      ),
      // No `chipTheme`: every chip is a `Pill` or `BrandChip` now, both of which
      // draw their own stadium. Same reason `elevatedButtonTheme` went.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: highContrast ? surface : brand.tints.first,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: field(Colors.transparent, 0),
        enabledBorder:
            field(highContrast ? text : Colors.transparent, highContrast ? 1.2 : 0),
        focusedBorder: field(primary, 1.6),
        errorBorder: field(scheme.error, 1.2),
        focusedErrorBorder: field(scheme.error, 1.6),
        labelStyle: TextStyle(color: muted),
        hintStyle: TextStyle(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
      ),
      // No `elevatedButtonTheme`: zero call sites.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: highContrast ? text : brand.hairline),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: text),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      // No `navigationBarTheme`: the shell uses `CurvedNavBar`, not
      // `NavigationBar`.
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        textColor: text,
        titleTextStyle: textTheme.bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(color: muted),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.field)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFF1C1512)
            : AppColors.tintsDark.first,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor: AppColors.coralSoft,
        insetPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.field)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: brand.hairline,
        circularTrackColor: brand.hairline,
        linearMinHeight: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : surface),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : brand.hairline),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : muted.withValues(alpha: 0.4)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: brand.hairline,
        thumbColor: Colors.white,
        overlayColor: primary.withValues(alpha: 0.12),
        trackHeight: 4,
      ),
      // No `tabBarTheme`: every tab strip is `FTabs` now, and this theme was
      // actively harmful — `TabBarThemeData.labelColor` takes precedence over
      // `labelStyle.color` inside Material's `TabBar`, which is what FTabs builds
      // on, so it silently overrode the branded forui tab colours.
      dialogTheme: DialogThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card)),
        titleTextStyle: textTheme.titleLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
        ),
      ),
    );
  }
}
