import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import 'brand.dart';

/// Shared presentational widgets. Everything here reads its colours from the
/// active [Theme] so light, dark and high-contrast all stay legible.

/// How a [BrandButton] reads.
enum BrandButtonKind { primary, outline, ghost, danger }

/// A button in the brand's shape.
///
/// forui's buttons are rounded rectangles; the brand makes everything tappable a
/// full pill. Rather than repeat that override at 50 call sites, screens use this
/// and never touch [FButton] directly.
class BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BrandButtonKind kind;
  final HugeIconData? icon;

  /// Whether the button stretches to its parent's width.
  final bool expand;

  final bool small;

  const BrandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = BrandButtonKind.primary,
    this.icon,
    this.expand = true,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    // Outlined buttons keep the hairline the rest of the design uses, or the text
    // colour at high contrast where the hairline is too faint to read.
    final side = switch (kind) {
      BrandButtonKind.outline => BorderSide(
          color: context.brand.tints.toSet().length == 1
              ? Theme.of(context).colorScheme.onSurface
              : context.brand.hairline,
        ),
      _ => BorderSide.none,
    };

    return FButton(
      onPress: onPressed,
      variant: switch (kind) {
        BrandButtonKind.primary => .primary,
        BrandButtonKind.outline => .outline,
        BrandButtonKind.ghost => .ghost,
        BrandButtonKind.danger => .destructive,
      },
      size: small ? .sm : .md,
      mainAxisSize: expand ? .max : .min,
      // Applied to the base and every interaction variant, so hover and pressed
      // stay pills too.
      style: .delta(decoration: .delta([.all(.shapeDelta(shape: StadiumBorder(side: side)))])),
      prefix: icon == null ? null : AppIcon(icon!, size: 18),
      child: Text(label),
    );
  }
}

/// The bold section title from the reference screens ("My Plans", "Activities"),
/// with an optional trailing text action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  const SectionHeader(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(bottom: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    letterSpacing: -0.4,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null)
            FButton(
              onPress: onAction,
              variant: .ghost,
              size: .sm,
              mainAxisSize: .min,
              // The coral is set on the Text rather than through the style so it
              // wins over the ghost variant's foreground, which is body colour.
              child: Text(
                actionLabel!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final HugeIconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outline;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A tinted disc behind the glyph, echoing the pastel cards.
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.brand.tint(0),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon,
                  size: 38, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              BrandButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Renders the three states of an [AsyncValue]-backed list without every screen
/// re-implementing the same loading spinner and error text.
class AsyncSection extends StatelessWidget {
  final bool isLoading;
  final Object? error;
  final Widget child;

  const AsyncSection({
    super.key,
    required this.isLoading,
    required this.error,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: FCircularProgress()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AppIcon(AppIcons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            Expanded(child: Text('Something went wrong: $error')),
          ],
        ),
      );
    }
    return child;
  }
}

/// A rounded stat tile used on the dashboard and in the insights reports.
///
/// The fill rotates through the brand pastels via [tintIndex] so a grid of
/// these reads like the "My Plans" row rather than a wall of identical boxes.
class StatTile extends StatelessWidget {
  final HugeIconData icon;
  final Color color;
  final String label;
  final String value;
  final String? sublabel;
  final VoidCallback? onTap;
  final int tintIndex;

  const StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.sublabel,
    this.onTap,
    this.tintIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outline;
    return TintCard(
      tintIndex: tintIndex,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppIcon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  // Three of these fit across a phone, so the label has to
                  // shrink rather than ellipsise on the narrowest layout.
                  style: TextStyle(fontSize: 12, color: muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Flexible so a long value or sublabel shrinks instead of
          // overflowing the fixed-height grid cell it sits in.
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (sublabel != null)
            Flexible(
              child: Text(
                sublabel!,
                style: TextStyle(fontSize: 12, color: muted, height: 1.25),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

/// GitHub-style contribution heatmap. [intensityFor] returns 0.0–1.0 for a day.
class ContributionHeatmap extends StatelessWidget {
  final int days;
  final Color color;
  final double Function(DateTime day) intensityFor;
  final void Function(DateTime day)? onTapDay;
  final double cell;

  const ContributionHeatmap({
    super.key,
    required this.color,
    required this.intensityFor,
    this.days = 119, // 17 weeks
    this.onTapDay,
    this.cell = 14,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    // Pad to the start of that week so columns line up as Mon–Sun.
    final leading = start.weekday - 1;
    final total = leading + days;
    final weeks = (total / 7).ceil();
    final base = context.brand.hairline;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(weeks, (w) {
          return Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Column(
              children: List.generate(7, (d) {
                final index = w * 7 + d - leading;
                if (index < 0 || index >= days) {
                  return SizedBox(height: cell + 3, width: cell);
                }
                final day = start.add(Duration(days: index));
                final v = intensityFor(day).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: FTooltip(
                    tipBuilder: (_, _) =>
                        Text('${day.year}-${day.month}-${day.day}'),
                    semanticsLabel: '${day.year}-${day.month}-${day.day}',
                    child: GestureDetector(
                      onTap: onTapDay == null ? null : () => onTapDay!(day),
                      child: Container(
                        width: cell,
                        height: cell,
                        decoration: BoxDecoration(
                          color: v == 0
                              ? base
                              : color.withValues(alpha: 0.25 + v * 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

/// Labelled progress bar used for budgets, adherence and focus goals.
class LabeledProgress extends StatelessWidget {
  final String label;
  final String trailing;
  final double value; // 0..1, may exceed 1 to signal an overrun
  final Color color;

  const LabeledProgress({
    super.key,
    required this.label,
    required this.trailing,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final over = value > 1.0;
    final muted = Theme.of(context).colorScheme.outline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis),
            ),
            Text(trailing, style: TextStyle(color: muted, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        FDeterminateProgress(
          value: value.clamp(0.0, 1.0),
          semanticsLabel: label,
          // The 8px fully-rounded bar on a hairline track, with the fill turning
          // to the error colour once the value overruns.
          style: .delta(
            constraints: const BoxConstraints.tightFor(height: 8),
            trackDecoration: .boxDelta(
              color: context.brand.hairline,
              borderRadius: BorderRadius.circular(999),
            ),
            fillDecoration: .boxDelta(
              color: over ? Theme.of(context).colorScheme.error : color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }
}

/// Standard bottom-sheet chrome: grab handle, title and scroll-safe padding.
class SheetScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  const SheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    // The surface is the sheet's own responsibility now. Material's
    // bottomSheetTheme supplied the background and the 28px top corners;
    // showFSheet does not, and without this the page shows through the sheet.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: context.brand.hairline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 20, letterSpacing: -0.4),
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// forui bridges
// ---------------------------------------------------------------------------
//
// Screens go through the wrappers below rather than calling forui directly, so a
// forui default can never quietly override a brand value in one corner of the
// app. Each one is a thin shim: forui supplies behaviour, the brand supplies the
// colours, shapes and spacing.

/// A page built on [FScaffold].
///
/// Adds three things [FScaffold] does not provide:
///
///  * **A [Material] ancestor.** `flutter_quill`, `flutter_slidable`,
///    [Dismissible], `PopupMenuButton` and `DataTable` all assert on one and
///    throw "No Material widget found" without it. Injecting it here once covers
///    every page rather than every call site.
///  * **The content icon size.** [FScaffold] installs an [IconTheme] from
///    `FStyle.iconStyle`, which is sized for forui's own chevrons and loaders
///    (20). Content glyphs expect Material's 24, so that default is restored.
///  * **A floating action slot**, which forui has no equivalent for.
class BrandScaffold extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final Widget? footer;

  /// Rendered bottom-right over [child].
  final Widget? floatingAction;

  /// Whether [FScaffold] applies its own page padding. Off by default because
  /// the screens already pad themselves.
  final bool pad;

  final bool resizeToAvoidBottomInset;

  const BrandScaffold({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.floatingAction,
    this.pad = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget body = child;

    if (floatingAction != null) {
      body = Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(right: 16, bottom: 16, child: floatingAction!),
        ],
      );
    }

    return FScaffold(
      header: header,
      footer: footer,
      childPad: pad,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: IconTheme(
        data: IconThemeData(
          size: 24,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: body,
        ),
      ),
    );
  }
}

/// A list row built on [FTile].
///
/// Mirrors the [ListTile] API the screens already use so the 60-odd call sites
/// read the same, and keeps the brand's row radius and muted subtitle.
class BrandTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool enabled;
  final String? semanticsLabel;

  const BrandTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.enabled = true,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FTile(
      title: title,
      subtitle: subtitle,
      prefix: leading,
      suffix: trailing,
      onPress: onTap,
      onLongPress: onLongPress,
      selected: selected,
      enabled: enabled,
      semanticsLabel: semanticsLabel,
      style: .delta(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
        ),
        contentStyle: .delta(
          // forui tints a row's leading glyph with the primary colour. The brand
          // keeps them muted — the Material listTileTheme used `iconColor: muted`
          // — so a row of settings does not read as a column of coral. An
          // explicit colour on the glyph still wins over this.
          prefixIconStyle: .delta([
            .all(IconThemeDataDelta.delta(color: context.muted, size: 24)),
          ]),
        ),
      ),
    );
  }
}

/// A text input built on [FTextField].
///
/// The brand's fields are filled with the peach tint and rounded to
/// [AppRadii.field] rather than forui's bordered, unfilled default.
class BrandField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final int? maxLines;
  final int? minLines;
  final bool obscure;
  final bool autofocus;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmit;
  final Widget? suffix;
  final FocusNode? focusNode;

  const BrandField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.maxLines = 1,
    this.minLines,
    this.obscure = false,
    this.autofocus = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onSubmit,
    this.suffix,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final flattened = brand.tints.toSet().length == 1;

    return FTextField(
      control: .managed(controller: controller),
      label: label == null ? null : Text(label!),
      hint: hint,
      description: helper == null ? null : Text(helper!),
      maxLines: obscure ? 1 : maxLines,
      minLines: minLines,
      obscureText: obscure,
      autofocus: autofocus,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onSubmit: onSubmit,
      suffixBuilder: suffix == null ? null : (_, _, _) => suffix!,
      focusNode: focusNode,
      style: .delta(
        // At high contrast the tint flattens, so the field falls back to the
        // page surface and leans on its border instead.
        color: .delta([
          .all(flattened
              ? Theme.of(context).colorScheme.surface
              : brand.tint(0)),
        ]),
        // Only the resting border is replaced. forui derives the focused and
        // error borders from FColors, which are already the brand's coral and
        // danger — the same treatment the Material inputDecorationTheme gave.
        border: .delta([
          .base(OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.field),
            borderSide: flattened
                ? BorderSide(
                    color: Theme.of(context).colorScheme.onSurface, width: 1.2)
                : BorderSide.none,
          )),
        ]),
      ),
    );
  }
}

/// A settings row with a trailing switch, replacing [SwitchListTile].
class BrandSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;

  const BrandSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return BrandTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      semanticsLabel: title,
      trailing: FSwitch(
        value: value,
        onChange: onChanged,
        semanticsLabel: title,
        // forui's off-track is `colors.border`, which is the brand hairline —
        // invisible against the peach card these rows sit on. Material's switch
        // theme compensated with a muted track outline; forui's style has no
        // outline, so the off-track itself carries the contrast.
        style: .delta(
          trackColor: .delta([
            .base(context.muted.withValues(alpha: 0.28)),
          ]),
        ),
      ),
      onTap: onChanged == null ? null : () => onChanged!(!value),
    );
  }
}

/// A single-choice segmented control, replacing [SegmentedButton].
///
/// forui has no segmented button; [FSelectGroup] in its single-select mode is the
/// nearest equivalent and carries the same keyboard and semantics behaviour.
class BrandSegmented<T extends Object> extends StatelessWidget {
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;

  const BrandSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in options.entries)
          Pill(
            label: entry.value,
            color: theme.colorScheme.primary,
            selected: entry.key == selected,
            onTap: () => onSelected(entry.key),
          ),
      ],
    );
  }
}

/// The coral disc that floats over a list, replacing [FloatingActionButton].
class BrandFab extends StatelessWidget {
  final HugeIconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  const BrandFab({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 58,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FTooltip(
      tipBuilder: (_, _) => Text(tooltip),
      semanticsLabel: tooltip,
      child: FTappable(
        onPress: onPressed,
        semanticsLabel: tooltip,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: theme.colorScheme.primary,
            shape: const CircleBorder(),
            shadows: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.32),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: AppIcon(icon, size: size * 0.42, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// A value slider built on [FSlider].
///
/// [FSlider] works in track percentages; the screens think in real ranges
/// (0.85–1.6 for text scale, 5–120 for a dose count), so the conversion lives
/// here rather than at each call site.
class BrandSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;

  /// Number of steps between [min] and [max]. Null for a continuous slider.
  final int? divisions;

  final ValueChanged<double> onChanged;

  const BrandSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  @override
  State<BrandSlider> createState() => _BrandSliderState();
}

class _BrandSliderState extends State<BrandSlider> {
  late FContinuousSliderController _controller;

  double get _fraction =>
      ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _controller = _build();
  }

  FContinuousSliderController _build() => FContinuousSliderController(
        value: FSliderValue(max: _fraction),
        stepPercentage:
            widget.divisions == null ? 0.05 : 1 / widget.divisions!,
      );

  @override
  void didUpdateWidget(BrandSlider old) {
    super.didUpdateWidget(old);
    // Rebuild the controller only when the value moved from outside, otherwise
    // dragging would fight its own state.
    if (old.value != widget.value &&
        (_controller.value.max - _fraction).abs() > 0.001) {
      _controller.dispose();
      _controller = _build();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FSlider(
      control: .managedContinuous(
        controller: _controller,
        onChange: (v) => widget.onChanged(
          widget.min + v.max * (widget.max - widget.min),
        ),
      ),
    );
  }
}

/// Picks a time of day, returning minutes past midnight.
///
/// forui's time picker is a wheel widget rather than a modal, so it is hosted in
/// the brand's own sheet with a confirm action.
Future<int?> brandTimePicker(
  BuildContext context, {
  required int initialMinutes,
  String title = 'Pick a time',
}) async {
  final controller = FTimePickerController(
    time: FTime(initialMinutes ~/ 60, initialMinutes % 60),
  );

  final result = await brandSheet<int>(
    context: context,
    builder: (sheetContext) => SheetScaffold(
      title: title,
      actions: [
        FButton(
          variant: .ghost,
          size: .sm,
          mainAxisSize: .min,
          onPress: () => Navigator.of(sheetContext).pop(
            controller.value.hour * 60 + controller.value.minute,
          ),
          child: Text(
            'Done',
            style: TextStyle(
              color: Theme.of(sheetContext).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      child: SizedBox(
        height: 220,
        child: FTimePicker(control: .managed(controller: controller)),
      ),
    ),
  );

  controller.dispose();
  return result;
}

/// Shows a bottom sheet with the brand's chrome.
///
/// forui caps a modal sheet at 9/16 of the screen by default; the editors here
/// are taller than that, so the cap is lifted and height is left to the content
/// the way `isScrollControlled` did.
Future<T?> brandSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return showFSheet<T>(
    context: context,
    side: .btt,
    mainAxisMaxRatio: null,
    barrierDismissible: dismissible,
    builder: builder,
  );
}

/// Shows a message. Replaces `ScaffoldMessenger.showSnackBar`.
///
/// Styled from the values the Material `snackBarTheme` used — a near-black slab
/// with coral action text — and aligned to the bottom so it lands where the
/// snack bar used to rather than in forui's default corner.
void brandToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  showFToast(
    context: context,
    alignment: FToastAlignment.bottomCenter,
    duration: duration,
    title: Text(message),
    suffixBuilder: (actionLabel == null || onAction == null)
        ? null
        : (_, entry) => FButton(
              variant: .ghost,
              size: .sm,
              mainAxisSize: .min,
              onPress: () {
                entry.dismiss();
                onAction();
              },
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.coralSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
  );
}

/// A confirm/cancel dialog. Replaces `showDialog` + `AlertDialog`.
///
/// Returns true only when the confirming action is chosen.
Future<bool> brandConfirm(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showFDialog<bool>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      style: style,
      builder: (context, style) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.muted),
            ),
          ],
          const SizedBox(height: 20),
          BrandButton(
            label: confirmLabel,
            kind: destructive ? BrandButtonKind.danger : BrandButtonKind.primary,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 8),
          BrandButton(
            label: cancelLabel,
            kind: BrandButtonKind.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

/// Small colour swatch picker used by habits, projects and categories.
class ColorPickerRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  /// The warm brand family. Existing rows may still hold a colour from the old
  /// indigo palette; those render fine, they just show as unselected here.
  static const palette = <int>[
    0xFFFF6547, 0xFF3BB273, 0xFFF2A03D, 0xFFE5484D,
    0xFF9A6DD7, 0xFF3AAFB9, 0xFFE86FA0, 0xFF6C6C6C,
  ];

  const ColorPickerRow(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: palette.map((c) {
        final isSel = c == selected;
        return GestureDetector(
          onTap: () => onChanged(c),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Color(c),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSel
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: isSel
                ? const AppIcon(AppIcons.check, size: 18, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

/// Icon picker backed by one of the token maps in `AppIcons`.
class IconPickerRow extends StatelessWidget {
  final Map<String, HugeIconData> options;
  final String selected;
  final Color color;
  final ValueChanged<String> onChanged;

  const IconPickerRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.entries.map((e) {
        final isSel = e.key == selected;
        return GestureDetector(
          onTap: () => onChanged(e.key),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSel ? color.withValues(alpha: 0.18) : context.brand.tint(0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSel ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: AppIcon(e.value,
                size: 20,
                color: isSel ? color : Theme.of(context).colorScheme.outline),
          ),
        );
      }).toList(),
    );
  }
}
