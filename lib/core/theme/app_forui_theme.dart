import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import 'app_colors.dart';
import 'app_icons.dart';
import 'app_theme.dart';

/// The forui half of the theme, built from the same [BrandTokens] as the
/// Material half.
///
/// forui ships shadcn's visual language — neutral, small radii, hairline borders,
/// unfilled surfaces. That is close to the opposite of this app's coral design, so
/// nothing here is left at a forui default that carries a look: colours come from
/// [AppColors], radii from [AppRadii], the typeface from the brand font, and the
/// icon set from [AppIcons]. Every one of forui's ~50 widget styles derives from
/// these three token sets via its own `inherit` constructor, so getting the tokens
/// right brands the whole library at once.
FThemeData brandForuiTheme({
  required Brightness brightness,
  bool highContrast = false,
  bool compact = false,
  String locale = 'en',
}) {
  final t = AppTheme.tokens(
    brightness: brightness,
    highContrast: highContrast,
    compact: compact,
    locale: locale,
  );
  return brandForuiThemeFrom(t);
}

/// Builds the forui theme from already-resolved [BrandTokens].
FThemeData brandForuiThemeFrom(BrandTokens t) {
  final colors = _colors(t);
  var typography = _typography(t);
  var sizes = FSizes.inherit(touch: true);

  // Material expresses density as VisualDensity.compact, which forui has no
  // equivalent for. VisualDensity.compact trims 8px off a 48px target, so the
  // ~0.92 factor below lands in the same place; the type scales with it so rows
  // do not end up tight around full-size text.
  if (t.compact) {
    typography = typography.scale(sizeScalar: 0.94);
    sizes = sizes.scale(0.92);
  }

  final style = FStyle(
    formFieldStyle: FFormFieldStyle.inherit(
      colors: colors,
      typography: typography,
      touch: true,
    ),
    focusedOutlineStyle: FFocusedOutlineStyle(
      color: colors.primary,
      borderRadius: BorderRadius.circular(AppRadii.field),
    ),
    // forui's own chrome glyphs — chevrons, clear buttons, loaders. Sized off
    // forui's default rather than Material's 24 so they sit correctly inside
    // forui's rows; content icons pass their own size or read the IconTheme.
    iconStyle: IconThemeData(color: t.text, size: 20),
    sizes: sizes,
    tappableStyle: FTappableStyle(),
    borderRadius: _borderRadius,
    // A visible outline is the whole high-contrast strategy: the pastel fills
    // flatten, so the border has to carry the separation.
    borderWidth: t.highContrast ? 1.2 : 1,
    pagePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    // The brand is flat — every Material sub-theme sets elevation 0.
    shadow: const [],
  );

  return FThemeData(
    debugLabel: 'mySuite ${t.isDark ? 'dark' : 'light'}'
        '${t.highContrast ? ' highContrast' : ''}${t.compact ? ' compact' : ''}',
    colors: colors,
    typography: typography,
    style: style,
    icons: _icons,
    tabsStyle: _tabsStyle(colors, typography, style, t),
    touch: true,
    // The same instance the Material theme registers, so `context.brand` and
    // forui-side lookups can never disagree.
    extensions: [t.brand],
    dialogStyle: _dialogStyle(colors, typography, style),
  );
}

/// The dialog surface.
///
/// forui puts a dialog on `card` — the peach tint — which is also what a
/// `BrandField` fills with, so the inputs of a form dialog disappear into their
/// own surface. The `dialogTheme` this replaces used the page background and the
/// card radius; both come back here. Sheets already agree, through
/// `SheetScaffold`'s own `scaffoldBackgroundColor` surface.
///
/// Built by hand rather than through `FThemeData.copyWith`: that method does not
/// forward `icons`, so routing the theme through it silently resets every glyph
/// to Lucide.
FDialogStyle _dialogStyle(
  FColors colors,
  FTypography typography,
  FStyle style,
) => FDialogStyleDelta.delta(
  decoration: DecorationDelta.shapeDelta(
    color: colors.background,
    shape: RoundedSuperellipseBorder(
      side: BorderSide(color: colors.border, width: style.borderWidth),
      borderRadius: BorderRadius.circular(AppRadii.card),
    ),
  ),
)(
  FDialogStyle.inherit(
    style: style,
    colors: colors,
    typography: typography,
    hapticFeedback: const FHapticFeedback(),
    touch: true,
  ),
);

/// The tab strip, restyled as a row of [Pill]s.
///
/// forui's default is shadcn's segmented control: a filled track with a raised
/// white thumb. The app already has a selection-chip language — `Pill`, used for
/// the search filters and the module chips — so tabs borrow it instead of
/// introducing a second one: no track, a solid coral stadium behind the selected
/// label, muted labels elsewhere. The strip is full-bleed, which only works
/// because the track is gone.
FTabsStyle _tabsStyle(
  FColors colors,
  FTypography typography,
  FStyle style,
  BrandTokens t,
) => FTabsStyle(
  decoration: const BoxDecoration(),
  padding: const EdgeInsets.symmetric(horizontal: 12),
  // `.label` would shrink-wrap the text — forui's `_Tab` centres the label with
  // `widthFactor: 1`, so there is no padding hook to widen it. `.tab` fills the
  // tab's equal share of the strip instead, and only one is ever selected so
  // pills never abut.
  indicatorSize: FTabBarIndicatorSize.tab,
  indicatorDecoration: ShapeDecoration(
    color: t.primary,
    shape: StadiumBorder(
      // At high contrast the fill alone is not enough separation, matching how
      // cards grow an outline there.
      side: t.highContrast
          ? BorderSide(color: t.text, width: style.borderWidth)
          : BorderSide.none,
    ),
  ),
  labelTextStyle: FVariants.from(
    typography.body.sm.copyWith(
      fontWeight: FontWeight.w600,
      color: colors.mutedForeground,
    ),
    variants: {
      const [FTabVariant.selected]: TextStyleDelta.delta(color: t.onPrimary),
    },
  ),
  focusedOutlineStyle: style.focusedOutlineStyle,
);

/// The brand radius ramp.
///
/// forui's default ramp tops out at 26 and starts at 4; the brand's shapes are
/// softer throughout. The four tokens the design actually names — field 16,
/// tile 20, card 24, sheet 28 — are pinned to `lg`, `xl`, `xl2` and `xl3`, which
/// are the steps forui's fields, rows, cards and sheets respectively resolve to.
const _borderRadius = FBorderRadius(
  xs2: BorderRadius.all(Radius.circular(6)),
  xs: BorderRadius.all(Radius.circular(8)),
  sm: BorderRadius.all(Radius.circular(10)),
  md: BorderRadius.all(Radius.circular(14)),
  lg: BorderRadius.all(Radius.circular(AppRadii.field)),
  xl: BorderRadius.all(Radius.circular(AppRadii.tile)),
  xl2: BorderRadius.all(Radius.circular(AppRadii.card)),
  xl3: BorderRadius.all(Radius.circular(AppRadii.sheet)),
);

/// Maps the brand palette onto forui's paired background/foreground tokens.
///
/// The pairings are not always the obvious ones. shadcn's `secondary` and `muted`
/// are muted *surfaces* rather than accent colours, so they take the apricot tint
/// rather than `coralDeep`; putting an accent there would make every secondary
/// button a dark coral slab.
FColors _colors(BrandTokens t) {
  final dark = t.isDark;
  final tints = t.brand.tints;
  return FColors(
    brightness: t.brightness,
    systemOverlayStyle:
        dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    // Matches the scrim Material's showDialog/showModalBottomSheet use today.
    barrier: const Color(0x8A000000),
    background: t.background,
    foreground: t.text,
    primary: t.primary,
    primaryForeground: t.onPrimary,
    secondary: tints.length > 1 ? tints[1] : tints.first,
    secondaryForeground: t.text,
    muted: tints.length > 1 ? tints[1] : tints.first,
    mutedForeground: t.muted,
    destructive: t.error,
    destructiveForeground: Colors.white,
    error: t.error,
    errorForeground: Colors.white,
    // The rotating pastel fill. Flattens to white/black at high contrast because
    // BrandTokens already flattened the tints.
    card: tints.first,
    border: t.brand.hairline,
    extensions: [t.brand],
  );
}

/// Typography in the brand font.
///
/// `display` carries the heading treatment already used by the Material text
/// theme — heavy weight with negative tracking that opens up as sizes shrink.
/// `body` stays at default weight. forui's own size and line-height ramp is left
/// alone; its widgets lay out against those numbers.
FTypography _typography(BrandTokens t) {
  final family = t.fontFamily;

  TextStyle s(double size, double height, {FontWeight? weight, double? tracking}) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        height: height,
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: weight,
        letterSpacing: tracking,
      );

  // Tighter tracking the larger the type, mirroring app_theme.dart's -1 → -0.4.
  double tracking(double size) => switch (size) {
        >= 48 => -1,
        >= 36 => -0.8,
        >= 30 => -0.6,
        >= 22 => -0.5,
        >= 18 => -0.4,
        _ => -0.2,
      };

  FTypeface face({required bool heading}) => FTypeface(
        fontFamily: family,
        xs3: s(10, 1, weight: heading ? FontWeight.w700 : null),
        xs2: s(12, 1, weight: heading ? FontWeight.w700 : null),
        xs: s(14, 1.25, weight: heading ? FontWeight.w700 : null),
        sm: s(16, 1.5, weight: heading ? FontWeight.w700 : null),
        md: s(18, 1.75,
            weight: heading ? FontWeight.w700 : null,
            tracking: heading ? tracking(18) : null),
        lg: s(20, 1.75,
            weight: heading ? FontWeight.w700 : null,
            tracking: heading ? tracking(20) : null),
        xl: s(22, 2,
            weight: heading ? FontWeight.w700 : null,
            tracking: heading ? tracking(22) : null),
        xl2: s(30, 2.25,
            weight: heading ? FontWeight.w700 : null,
            tracking: heading ? tracking(30) : null),
        xl3: s(36, 2.5,
            weight: heading ? FontWeight.w700 : null,
            tracking: heading ? tracking(36) : null),
        xl4: s(48, 1,
            weight: heading ? FontWeight.w700 : null,
            tracking: heading ? tracking(48) : null),
        xl5: s(60, 1,
            weight: heading ? FontWeight.w700 : null,
            tracking: heading ? tracking(60) : null),
        xl6: s(72, 1, weight: heading ? FontWeight.w700 : null, tracking: heading ? -1 : null),
        xl7: s(96, 1, weight: heading ? FontWeight.w700 : null, tracking: heading ? -1 : null),
        xl8: s(108, 1, weight: heading ? FontWeight.w700 : null, tracking: heading ? -1 : null),
      );

  return FTypography(display: face(heading: true), body: face(heading: false));
}

/// forui's 22 icon tokens, drawn from Hugeicons stroke-rounded.
///
/// This override is not optional. Left at its `FIcons.lucide()` default, forui
/// would draw Lucide glyphs inside its own chrome — chevrons, clear buttons,
/// loaders, the password reveal — partially undoing the Hugeicons migration.
///
/// [AppIcon] is the bridge: a Hugeicons glyph is SVG path data rather than
/// [IconData], and raw `HugeIcon` hard-defaults its size to 24 instead of reading
/// the ambient [IconTheme], which is exactly what [AppIcon] fixes.
final _icons = FIcons(
  arrowLeft: _glyph(AppIcons.back),
  calendar: _glyph(AppIcons.today),
  check: _glyph(AppIcons.check),
  chevronDown: _glyph(AppIcons.chevronDown),
  chevronLeft: _glyph(AppIcons.chevronLeft),
  chevronRight: _glyph(AppIcons.chevronRight),
  chevronUp: _glyph(AppIcons.chevronUp),
  chevronsUpDown: _glyph(AppIcons.chevronsUpDown),
  circleAlert: _glyph(AppIcons.error),
  clock4: _glyph(AppIcons.clock),
  ellipsis: _glyph(AppIcons.moreHorizontal),
  error: _glyph(AppIcons.warning),
  eye: _glyph(AppIcons.eye),
  eyeClosed: _glyph(AppIcons.eyeClosed),
  gripHorizontal: _glyph(AppIcons.gripHorizontal),
  gripVertical: _glyph(AppIcons.gripVertical),
  loader: _glyph(AppIcons.loader),
  loaderCircle: _glyph(AppIcons.loaderCircle),
  loaderPinwheel: _glyph(AppIcons.loaderPinwheel),
  search: _glyph(AppIcons.search),
  userRound: _glyph(AppIcons.person),
  x: _glyph(AppIcons.close),
);

FIconBuilder _glyph(HugeIconData icon) =>
    (_, {String? semanticsLabel}) => AppIcon(icon, semanticsLabel: semanticsLabel);
