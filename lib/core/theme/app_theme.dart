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

  static ThemeData light({
    bool highContrast = false,
    bool compact = false,
    String locale = 'en',
  }) {
    final text = highContrast ? Colors.black : AppColors.textLight;
    final muted = highContrast ? const Color(0xFF3D3D3D) : AppColors.mutedLight;
    return _build(
      brightness: Brightness.light,
      scheme: ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: AppColors.coralDeep,
        surface: AppColors.surfaceLight,
        error: AppColors.dangerLight,
        onSurface: text,
        outline: muted,
        // `surfaceContainer` is the pastel fill Material picks for grouped
        // content, so pointing it at the peach tint brands stock widgets too.
        surfaceContainer: AppColors.tintPeach,
        surfaceContainerHighest: AppColors.tintApricot,
      ),
      background: highContrast ? Colors.white : AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      text: text,
      muted: muted,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      brand: BrandColors(
        tints: highContrast
            // Pastel fills wash out at high contrast, so cards fall back to
            // white and lean on the stronger outline instead.
            ? const [Colors.white, Colors.white, Colors.white]
            : AppColors.tints,
        hairline: highContrast ? const Color(0xFF9A9A9A) : AppColors.hairlineLight,
        canvas: Colors.white,
      ),
      compact: compact,
      locale: locale,
      highContrast: highContrast,
    );
  }

  static ThemeData dark({
    bool highContrast = false,
    bool compact = false,
    String locale = 'en',
  }) {
    final text = highContrast ? Colors.white : AppColors.textDark;
    final muted = highContrast ? const Color(0xFFD8D0CE) : AppColors.mutedDark;
    return _build(
      brightness: Brightness.dark,
      scheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: const Color(0xFF3A1206),
        secondary: AppColors.coralSoft,
        surface: AppColors.surfaceDark,
        error: AppColors.dangerDark,
        onSurface: text,
        outline: muted,
        surfaceContainer: AppColors.tintsDark.first,
        surfaceContainerHighest: AppColors.tintsDark.last,
      ),
      background: highContrast ? Colors.black : AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      text: text,
      muted: muted,
      primary: AppColors.primaryDark,
      onPrimary: const Color(0xFF3A1206),
      brand: BrandColors(
        tints: highContrast
            ? const [Colors.black, Colors.black, Colors.black]
            : AppColors.tintsDark,
        hairline: highContrast ? const Color(0xFF6E6E6E) : AppColors.hairlineDark,
        canvas: highContrast ? Colors.black : AppColors.backgroundDark,
      ),
      compact: compact,
      locale: locale,
      highContrast: highContrast,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color background,
    required Color surface,
    required Color text,
    required Color muted,
    required Color primary,
    required Color onPrimary,
    required BrandColors brand,
    required bool compact,
    required bool highContrast,
    required String locale,
  }) {
    final base =
        brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();
    final textTheme = _textTheme(base.textTheme, text, locale);

    // Cards are normally borderless — the pastel fill does the separating. At
    // high contrast the fill disappears, so a real outline takes over.
    final cardBorder = highContrast
        ? BorderSide(color: text, width: 1.2)
        : BorderSide.none;

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
      chipTheme: ChipThemeData(
        backgroundColor: brand.tints.first,
        selectedColor: primary,
        side: highContrast ? BorderSide(color: text) : BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: TextStyle(
            color: text, fontSize: 13, fontWeight: FontWeight.w600),
        secondaryLabelStyle: TextStyle(
            color: onPrimary, fontSize: 13, fontWeight: FontWeight.w600),
      ),
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? primary : muted,
          ),
        ),
      ),
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
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: muted,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primary, width: 3),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
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
