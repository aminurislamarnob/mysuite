import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The colour palettes a user can pick between.
///
/// A palette owns colour and nothing else — radii, typeface, spacing and
/// density are the same whichever is active, so the app stays recognisably
/// itself rather than pretending to be four different products.
///
/// Persisted by `name`, never by `index`: inserting a palette into the middle
/// of this list must not silently reassign anyone's saved choice.
enum AppPalette { coral, magenta, cobalt, aubergine }

extension AppPaletteX on AppPalette {
  String get label => switch (this) {
    AppPalette.coral => 'Coral',
    AppPalette.magenta => 'Magenta',
    AppPalette.cobalt => 'Cobalt',
    AppPalette.aubergine => 'Aubergine',
  };

  String get blurb => switch (this) {
    AppPalette.coral => 'The warm default',
    AppPalette.magenta => 'Hot pink on white',
    AppPalette.cobalt => 'Cool, crisp blue',
    AppPalette.aubergine => 'Deep plum',
  };

  /// The pair of appearances this palette resolves to.
  PaletteSpec spec(Brightness brightness) =>
      brightness == Brightness.dark ? _specs[this]!.dark : _specs[this]!.light;

  /// The swatch shown in the picker — the light primary, so the four read
  /// apart at a glance regardless of the theme currently in force.
  Color get swatch => _specs[this]!.light.primary;

  /// Resolves a saved preference, falling back to the default rather than
  /// throwing on a name this build does not know.
  static AppPalette byName(String? name) =>
      AppPalette.values.where((p) => p.name == name).firstOrNull ??
      AppPalette.coral;
}

/// One palette resolved for one brightness.
///
/// Sixteen authored colours. The card tints, and the medicine accent, are
/// derived — see [tints] and [medicine].
@immutable
class PaletteSpec {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color text;
  final Color muted;
  final Color hairline;

  final Color success;
  final Color warning;
  final Color danger;

  final Color note;
  final Color habit;
  final Color task;
  final Color expense;
  final Color focus;

  /// Set only where a palette pins its own card fills. Coral does, to keep the
  /// hand-picked peach/apricot/cream rotation the design shipped with; every
  /// other palette derives them from its primary.
  final List<Color>? tintOverride;

  const PaletteSpec({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.text,
    required this.muted,
    required this.hairline,
    required this.success,
    required this.warning,
    required this.danger,
    required this.note,
    required this.habit,
    required this.task,
    required this.expense,
    required this.focus,
    this.tintOverride,
  });

  /// The flagship module carries the brand, in every palette. A getter rather
  /// than a field so the convention cannot be broken by a typo in the table.
  Color get medicine => primary;

  /// The three rotating card fills: the primary laid over the page at rising
  /// densities, which is the same relationship the hand-picked coral tints
  /// have to coral.
  List<Color> get tints =>
      tintOverride ??
      [
        for (final a in const [0.04, 0.07, 0.10])
          Color.alphaBlend(primary.withValues(alpha: a), background),
      ];
}

const _specs = <AppPalette, ({PaletteSpec light, PaletteSpec dark})>{
  AppPalette.coral: (
    light: PaletteSpec(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onCoral,
      secondary: AppColors.coralDeep,
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      text: AppColors.textLight,
      muted: AppColors.mutedLight,
      hairline: AppColors.hairlineLight,
      success: AppColors.successLight,
      warning: AppColors.warningLight,
      danger: AppColors.dangerLight,
      note: AppColors.noteAccent,
      habit: AppColors.habitAccent,
      task: AppColors.taskAccent,
      expense: AppColors.expenseAccent,
      focus: AppColors.focusAccent,
      tintOverride: AppColors.tints,
    ),
    dark: PaletteSpec(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onCoral,
      secondary: AppColors.coralSoft,
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      text: AppColors.textDark,
      muted: AppColors.mutedDark,
      hairline: AppColors.hairlineDark,
      success: AppColors.successDark,
      warning: AppColors.warningDark,
      danger: AppColors.dangerDark,
      note: AppColors.noteAccentDark,
      habit: AppColors.habitAccentDark,
      task: AppColors.taskAccentDark,
      expense: AppColors.expenseAccentDark,
      focus: AppColors.focusAccentDark,
      tintOverride: AppColors.tintsDark,
    ),
  ),
  AppPalette.magenta: (
    light: PaletteSpec(
      primary: Color(0xFFC4126A),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF8E0B4C),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF120A0E),
      muted: Color(0xFF665C63),
      hairline: Color(0xFFF3EFF1),
      success: Color(0xFF2C8655),
      warning: Color(0xFFA76808),
      danger: Color(0xFFB32020),
      note: Color(0xFFC38131),
      habit: Color(0xFF2C8655),
      task: Color(0xFF3A67C9),
      expense: Color(0xFF5B45D6),
      focus: Color(0xFF0D8390),
    ),
    dark: PaletteSpec(
      primary: Color(0xFFFF6BAB),
      onPrimary: Color(0xFF2B0217),
      secondary: Color(0xFFFFA9CB),
      background: Color(0xFF150F12),
      surface: Color(0xFF201A1D),
      text: Color(0xFFF6EFF2),
      muted: Color(0xFFA99DA4),
      hairline: Color(0xFF2E2529),
      success: Color(0xFF55CC8B),
      warning: Color(0xFFF5B457),
      danger: Color(0xFFFF6B6F),
      note: Color(0xFFF5B457),
      habit: Color(0xFF55CC8B),
      task: Color(0xFF7FA3F5),
      expense: Color(0xFFA48CF5),
      focus: Color(0xFF47C3CF),
    ),
  ),
  AppPalette.cobalt: (
    light: PaletteSpec(
      primary: Color(0xFF1264D4),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF0C4695),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF0A0D12),
      muted: Color(0xFF5C636E),
      hairline: Color(0xFFEEF0F3),
      success: Color(0xFF2C8655),
      warning: Color(0xFFA76808),
      danger: Color(0xFFC0271F),
      note: Color(0xFFC38131),
      habit: Color(0xFF2C8655),
      task: Color(0xFF0E8577),
      expense: Color(0xFF8A4FD1),
      focus: Color(0xFF5B6B7C),
    ),
    dark: PaletteSpec(
      primary: Color(0xFF6BA5FF),
      onPrimary: Color(0xFF041129),
      secondary: Color(0xFFA8CBFF),
      background: Color(0xFF0E1116),
      surface: Color(0xFF181D24),
      text: Color(0xFFEFF2F6),
      muted: Color(0xFF9CA6B3),
      hairline: Color(0xFF232A33),
      success: Color(0xFF55CC8B),
      warning: Color(0xFFF5B457),
      danger: Color(0xFFFF6B6F),
      note: Color(0xFFF5B457),
      habit: Color(0xFF55CC8B),
      task: Color(0xFF3FBFAE),
      expense: Color(0xFFB58DEC),
      focus: Color(0xFF8CA0B4),
    ),
  ),
  AppPalette.aubergine: (
    light: PaletteSpec(
      primary: Color(0xFF5B1F5E),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF3D0F40),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF1A121B),
      muted: Color(0xFF665C69),
      hairline: Color(0xFFF2EFF3),
      success: Color(0xFF2C8655),
      warning: Color(0xFFA76808),
      danger: Color(0xFFB32020),
      note: Color(0xFFC38131),
      habit: Color(0xFF2C8655),
      task: Color(0xFF3A67C9),
      expense: Color(0xFFA85A3C),
      focus: Color(0xFF0D8390),
    ),
    dark: PaletteSpec(
      primary: Color(0xFFC88BCC),
      onPrimary: Color(0xFF24052A),
      secondary: Color(0xFFE0B8E3),
      background: Color(0xFF17121A),
      surface: Color(0xFF221B26),
      text: Color(0xFFF3EEF4),
      muted: Color(0xFFA79BAA),
      hairline: Color(0xFF302838),
      success: Color(0xFF55CC8B),
      warning: Color(0xFFF5B457),
      danger: Color(0xFFFF6B6F),
      note: Color(0xFFF5B457),
      habit: Color(0xFF55CC8B),
      task: Color(0xFF7FA3F5),
      expense: Color(0xFFD8896B),
      focus: Color(0xFF47C3CF),
    ),
  ),
};
