import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the light and dark [ThemeData] for mySuite using the spec's design
/// tokens: 12px card radius, 8px input radius, 999px pills, Inter typography.
class AppTheme {
  AppTheme._();

  static const _inputRadius = 12.0;

  static ThemeData light(Color accent) => _build(
        brightness: Brightness.light,
        seed: accent,
        scaffold: AppColors.bgLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textLight,
        muted: AppColors.mutedLight,
      );

  static ThemeData dark(Color accent) => _build(
        brightness: Brightness.dark,
        seed: accent,
        scaffold: AppColors.bgDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textDark,
        muted: AppColors.mutedDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color seed,
    required Color scaffold,
    required Color surface,
    required Color onSurface,
    required Color muted,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ).copyWith(
      surface: surface,
      onSurface: onSurface,
    );

    final textTheme = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(bodyColor: onSurface, displayColor: onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: muted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        side: BorderSide.none,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? scheme.primary : muted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? scheme.primary : muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
        thickness: 1,
        space: 1,
      ),
      extensions: [AppPalette(muted: muted)],
    );
  }
}

/// Exposes tokens that don't map cleanly onto [ColorScheme] (e.g. "muted" text)
/// so widgets can read them via `Theme.of(context).extension<AppPalette>()`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({required this.muted});

  final Color muted;

  @override
  AppPalette copyWith({Color? muted}) => AppPalette(muted: muted ?? this.muted);

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(muted: Color.lerp(muted, other.muted, t) ?? muted);
  }
}

extension AppThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  Color get muted =>
      Theme.of(this).extension<AppPalette>()?.muted ?? AppColors.mutedLight;
}
