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
      style: .delta(
        decoration: .delta([
          .all(.shapeDelta(shape: StadiumBorder(side: side))),
        ]),
      ),
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
              child: AppIcon(
                icon,
                size: 38,
                color: Theme.of(context).colorScheme.primary,
              ),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: muted),
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
        child: Center(child: BrandSpinner()),
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
                letterSpacing: -0.5,
              ),
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
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: days - 1));
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
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(trailing, style: TextStyle(color: muted, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        // The fill turns to the error colour once the value overruns.
        BrandProgressBar(
          value: value,
          semanticsLabel: label,
          color: over ? Theme.of(context).colorScheme.error : color,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          letterSpacing: -0.4,
                        ),
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
        child: Material(type: MaterialType.transparency, child: body),
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

  /// Tightens the row for long lists. forui gives every tile 14.5px above
  /// and below its content, so a stack of them reads as a column of islands;
  /// dense rows keep the horizontal inset and halve the vertical.
  final bool dense;

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
    this.dense = false,
  });

  /// The content inset of a dense row; see [dense].
  static const densePadding = EdgeInsets.symmetric(horizontal: 15, vertical: 7);

  @override
  Widget build(BuildContext context) {
    final padding = dense
        ? const EdgeInsetsGeometryDelta.value(densePadding)
        : null;
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
          suffixedPadding: padding,
          unsuffixedPadding: padding,
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
class BrandField extends StatefulWidget {
  /// Distance from the field's edge to a [prefix] or [suffix]. Matches the
  /// horizontal padding forui's `FTile` gives a [BrandTile]'s leading glyph.
  static const double affixInset = 15;

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;

  /// A validation message, shown in the error colour and switching the field to
  /// its error variant.
  final String? error;

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

  /// Called on every keystroke, like [TextField.onChanged].
  final ValueChanged<String>? onChanged;

  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;

  /// Overrides the input text's own style, for the one field that is a display
  /// figure rather than body copy — the expense sheet's amount.
  final TextStyle? textStyle;

  /// Drops the fill and the border, for a field that reads as a heading rather
  /// than an input — the note editor's title, which sits flush above the Quill
  /// body and would look boxed-in with the usual treatment.
  final bool bare;

  const BrandField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.error,
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
    this.onChanged,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.textStyle,
    this.bare = false,
  });

  @override
  State<BrandField> createState() => _BrandFieldState();
}

class _BrandFieldState extends State<BrandField> {
  // forui only renders `FTextField.error` when the field is in the error
  // WidgetState; passing `error:` alone is inert. We drive that state from the
  // presence of an error message so a plain BrandField (no Form) still shows it.
  final WidgetStatesController _states = WidgetStatesController();

  @override
  void initState() {
    super.initState();
    _states.update(WidgetState.error, widget.error != null);
  }

  @override
  void didUpdateWidget(BrandField old) {
    super.didUpdateWidget(old);
    if (widget.error != old.error) {
      _states.update(WidgetState.error, widget.error != null);
    }
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final flattened = brand.tints.toSet().length == 1;

    return FTextField(
      control: .managed(
        controller: widget.controller,
        onChange: widget.onChanged == null
            ? null
            : (v) => widget.onChanged!(v.text),
      ),
      statesController: _states,
      label: widget.label == null ? null : Text(widget.label!),
      hint: widget.hint,
      description: widget.helper == null ? null : Text(widget.helper!),
      error: widget.error == null ? null : Text(widget.error!),
      maxLines: widget.obscure ? 1 : widget.maxLines,
      minLines: widget.minLines,
      obscureText: widget.obscure,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      onSubmit: widget.onSubmit,
      // forui zeroes the field's leading contentPadding the moment a prefix
      // exists, and clears the prefix's minimum box, so an unwrapped prefix
      // sits flush against the border. The inset is the one `BrandTile` gives
      // its leading glyph, so a field's symbol lines up with the row icons
      // stacked under it; the trailing gap separates it from the text.
      prefixBuilder: widget.prefix == null
          ? null
          : (_, _, _) => Padding(
              padding: const EdgeInsetsDirectional.only(
                start: BrandField.affixInset,
                end: 8,
              ),
              child: widget.prefix!,
            ),
      // The same applies on the trailing edge.
      suffixBuilder: widget.suffix == null
          ? null
          : (_, _, _) => Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 8,
                end: BrandField.affixInset,
              ),
              child: widget.suffix!,
            ),
      focusNode: widget.focusNode,
      style: .delta(
        contentTextStyle: widget.textStyle == null
            ? null
            : .delta([.all(TextStyleDelta.value(widget.textStyle!))]),
        // forui builds the hint from the theme's body style and never from
        // contentTextStyle, so a field that sets its own text size would show
        // a hint several sizes smaller than the text that replaces it.
        hintTextStyle: widget.textStyle == null
            ? null
            : .delta([
                .all(
                  TextStyleDelta.value(
                    widget.textStyle!.copyWith(color: context.muted),
                  ),
                ),
              ]),
        // At high contrast the tint flattens, so the field falls back to the
        // page surface and leans on its border instead.
        color: .delta([
          .all(
            widget.bare
                ? Colors.transparent
                : flattened
                ? Theme.of(context).colorScheme.surface
                : brand.tint(0),
          ),
        ]),
        // Only the resting border is replaced. forui derives the focused and
        // error borders from FColors, which are already the brand's coral and
        // danger — the same treatment the Material inputDecorationTheme gave.
        border: .delta([
          if (widget.bare)
            .all(InputBorder.none)
          else
            .base(
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.field),
                borderSide: flattened
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 1.2,
                      )
                    : BorderSide.none,
              ),
            ),
        ]),
      ),
    );
  }
}

/// A dismissible label, replacing Material's [Chip] with `onDeleted`.
///
/// Shares [Pill]'s unselected look — hairline stadium on the canvas — with a
/// trailing close glyph, so a row of these matches the filter chips elsewhere.
class BrandChip extends StatelessWidget {
  final String label;
  final HugeIconData? icon;
  final VoidCallback? onRemove;

  const BrandChip({super.key, required this.label, this.icon, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.brand.canvas,
        shape: StadiumBorder(side: BorderSide(color: context.brand.hairline)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 12, right: onRemove == null ? 12 : 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(icon!, size: 13, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onRemove != null)
              CircleIconButton(
                icon: AppIcons.close,
                tooltip: 'Remove $label',
                size: 28,
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}

/// A checkbox, replacing Material's [Checkbox].
///
/// [color] overrides the checked fill for callers that tick in a module accent
/// rather than the brand coral — the task subtask list is the one that does.
class BrandCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? color;
  final String? semanticsLabel;

  const BrandCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.color,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FCheckbox(
      value: value,
      onChange: onChanged,
      semanticsLabel: semanticsLabel,
      style: color == null
          ? const .context()
          : .delta(
              // `.match` rewrites only the constraints satisfied by {selected},
              // so the checked fill changes and the disabled and error boxes
              // keep forui's derivations.
              decoration: .delta([
                .match({
                  FCheckboxVariant.selected,
                }, DecorationDelta.shapeDelta(color: color)),
              ]),
            ),
    );
  }
}

/// A busy indicator, replacing Material's [CircularProgressIndicator].
///
/// Every loading state in the app is this one ring at forui's derived size, so
/// the wrapper carries no knobs — a change of mind lands here, not in fifteen
/// screens.
class BrandSpinner extends StatelessWidget {
  const BrandSpinner({super.key});

  @override
  Widget build(BuildContext context) => const FCircularProgress();
}

/// A hairline rule, replacing Material's [Divider].
///
/// forui reads its colour and thickness from `FStyle`, which already carries
/// the brand hairline, so there is nothing to override here.
class BrandDivider extends StatelessWidget {
  const BrandDivider({super.key});

  @override
  Widget build(BuildContext context) => const FDivider();
}

/// A tap target, replacing [InkWell] and [GestureDetector].
///
/// forui supplies the hit test, focus ring and press haptics. Nothing is
/// restyled; this exists so a screen never has to reach for forui to make an
/// arbitrary widget tappable.
class BrandTappable extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final Widget child;

  const BrandTappable({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) => FTappable(
    onPress: onPressed,
    semanticsLabel: semanticsLabel,
    child: child,
  );
}

/// A tooltip, replacing Material's [Tooltip].
///
/// Takes a message rather than forui's builder: every tip in the app is one
/// line of text. The `FTooltipGroup` in `main.dart` already keeps only one of
/// these open at a time.
class BrandTooltip extends StatelessWidget {
  final String message;
  final String? semanticsLabel;
  final Widget child;

  const BrandTooltip({
    super.key,
    required this.message,
    required this.child,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) => FTooltip(
    tipBuilder: (_, _) => Text(message),
    semanticsLabel: semanticsLabel,
    child: child,
  );
}

/// A progress bar, replacing Material's [LinearProgressIndicator].
///
/// forui's own bar is a squared-off fill on a filled track; the brand's is a
/// fully-rounded fill on a hairline one. [LabeledProgress] and the onboarding
/// step indicator differ only in height, so both come through here rather than
/// repeating the same three deltas.
class BrandProgressBar extends StatelessWidget {
  final double value; // 0..1; anything above is clamped
  final Color color;
  final double height;
  final String? semanticsLabel;

  const BrandProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) => FDeterminateProgress(
    value: value.clamp(0.0, 1.0),
    semanticsLabel: semanticsLabel,
    style: .delta(
      constraints: BoxConstraints.tightFor(height: height),
      trackDecoration: .boxDelta(
        color: context.brand.hairline,
        borderRadius: BorderRadius.circular(999),
      ),
      fillDecoration: .boxDelta(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );
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
          trackColor: .delta([.base(context.muted.withValues(alpha: 0.28))]),
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

  /// Optional leading glyph per option, keyed the same way as [options].
  final Map<T, HugeIconData> icons;

  const BrandSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.icons = const {},
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
            icon: icons[entry.key],
            color: theme.colorScheme.primary,
            selected: entry.key == selected,
            onTap: () => onSelected(entry.key),
          ),
      ],
    );
  }
}

/// A collapsible row, replacing Material's `ExpansionTile`.
///
/// forui's `FAccordion` indents its title by nothing and takes no leading
/// glyph, so a bare one sitting in a card of [BrandTile]s reads as a different
/// widget: flush to the card edge, with a hole where every neighbour has an
/// icon. This matches [BrandTile]'s inset, 8px icon gap and muted 24px glyph so
/// the row lines up with the ones above it. The inset is 14, not 10: `FItem`
/// puts its content inside a 4px `FItemStyle.padding` before the content's own
/// 10px, and the accordion has no equivalent outer padding of its own.
class BrandAccordion extends StatefulWidget {
  final String title;
  final HugeIconData? leading;
  final Widget child;

  const BrandAccordion({
    super.key,
    required this.title,
    required this.child,
    this.leading,
  });

  @override
  State<BrandAccordion> createState() => _BrandAccordionState();
}

class _BrandAccordionState extends State<BrandAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => FAccordion(
    // Lifted rather than managed. A managed `FAccordionItem` resets its reveal
    // animation to `initiallyExpanded` in `didChangeDependencies`, so anything
    // that changes an inherited widget above it snaps the panel shut —
    // flipping a switch *inside* the panel closed it under the user's finger.
    // With lifted state the item follows this flag instead of resetting.
    control: .lifted(
      expanded: (_) => _expanded,
      onChange: (_, expanded) => setState(() => _expanded = expanded),
    ),
    style: .delta(
      titlePadding: EdgeInsetsGeometryDelta.value(
        const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
      childPadding: EdgeInsetsGeometryDelta.value(
        const EdgeInsets.fromLTRB(14, 0, 14, 16),
      ),
    ),
    children: [
      FAccordionItem(
        title: Row(
          children: [
            if (widget.leading != null) ...[
              AppIcon(widget.leading!, size: 24, color: context.muted),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(widget.title)),
          ],
        ),
        child: widget.child,
      ),
    ],
  );
}

/// A tab strip plus its views, replacing Material's `TabBar` + `TabBarView`.
///
/// Always scrollable: the strip's pills size to their labels, so a long label
/// like "Overview" cannot be squeezed into an equal-width slot and wrapped.
class BrandTabs extends StatelessWidget {
  /// The tab labels, in order, mapped to the view each one shows.
  final Map<String, Widget> tabs;

  const BrandTabs({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) => FTabs(
    scrollable: true,
    expands: true,
    children: [
      for (final entry in tabs.entries)
        FTabEntry(label: Text(entry.key), child: entry.value),
    ],
  );
}

/// An overflow menu, replacing Material's [PopupMenuButton].
///
/// The trigger is the same [CircleIconButton] used for every other row action,
/// so the affordance matches the rest of the app rather than Material's bare
/// icon and grey card.
class BrandMenuButton<T extends Object> extends StatelessWidget {
  /// The menu entries, in order, keyed by the value handed to [onSelected].
  final Map<T, String> items;
  final ValueChanged<T> onSelected;
  final HugeIconData icon;
  final String tooltip;

  const BrandMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.icon = AppIcons.moreVertical,
    this.tooltip = 'More',
  });

  @override
  Widget build(BuildContext context) => FPopoverMenu(
    menuBuilder: (context, controller, _) => [
      FItemGroup(
        children: [
          for (final entry in items.entries)
            FItem(
              title: Text(entry.value),
              // The menu does not dismiss itself on selection.
              onPress: () {
                controller.hide();
                onSelected(entry.key);
              },
            ),
        ],
      ),
    ],
    builder: (context, controller, _) => CircleIconButton(
      icon: icon,
      tooltip: tooltip,
      size: 40,
      onPressed: controller.toggle,
    ),
  );
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
    stepPercentage: widget.divisions == null ? 0.05 : 1 / widget.divisions!,
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
        onChange: (v) =>
            widget.onChanged(widget.min + v.max * (widget.max - widget.min)),
      ),
    );
  }
}

/// Picks a date, replacing `showDatePicker`.
///
/// forui's calendar is a widget rather than a modal, so it is hosted in the
/// brand's sheet. Tapping a day closes the sheet, matching the one-tap feel of
/// the Material picker rather than requiring a separate confirm.
Future<DateTime?> brandDatePicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? first,
  DateTime? last,
  String title = 'Pick a date',
}) {
  final now = DateTime.now();
  return brandSheet<DateTime>(
    context: context,
    builder: (sheetContext) => SheetScaffold(
      title: title,
      child: FCalendar.grid(
        selectionControl: FDateSelectionControl.managedSingle(initial: initial),
        control: FGridCalendarControl(
          start: first ?? DateTime(now.year - 5),
          end: last ?? DateTime(now.year + 5),
          initial: initial ?? now,
        ),
        onDayPress: (day) => Navigator.of(sheetContext).pop(day),
      ),
    ),
  );
}

/// Picks an inclusive date range, replacing `showDateRangePicker`.
///
/// Unlike [brandDatePicker] this cannot close on tap — a range needs two taps —
/// so it carries an explicit confirm, disabled until both ends are chosen.
Future<(DateTime, DateTime)?> brandDateRangePicker(
  BuildContext context, {
  required DateTime first,
  required DateTime last,
  (DateTime, DateTime)? initial,
  String title = 'Pick a range',
}) {
  var range = initial;
  return brandSheet<(DateTime, DateTime)>(
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (_, setState) => SheetScaffold(
        title: title,
        actions: [
          BrandButton(
            label: 'Done',
            expand: false,
            onPressed: range == null
                ? null
                : () => Navigator.of(sheetContext).pop(range),
          ),
        ],
        child: FCalendar.grid(
          selectionControl: FDateSelectionControl.managedRange(
            initial: initial,
            onChange: (v) => setState(() => range = v),
          ),
          control: FGridCalendarControl(
            start: first,
            end: last,
            initial: initial?.$1 ?? first,
          ),
        ),
      ),
    ),
  );
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
          onPress: () => Navigator.of(
            sheetContext,
          ).pop(controller.value.hour * 60 + controller.value.minute),
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
    // The shell's tab bar lives above the tab navigators, so a modal opened
    // in one would sit under it. The root navigator covers the whole screen.
    useRootNavigator: true,
    side: .btt,
    mainAxisMaxRatio: null,
    barrierDismissible: dismissible,
    builder: builder,
  );
}

/// Slides a panel in from the leading edge, replacing Material's `Drawer`.
///
/// `Drawer` needs a `Scaffold` to host it and an app bar to offer the hamburger,
/// neither of which [BrandScaffold] provides. forui's `FSidebar` is a persistent
/// panel rather than a modal, so the drawer screens present their filter panel as
/// a left-hand sheet instead, opened from an explicit header button.
Future<T?> brandSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showFSheet<T>(
    context: context,
    useRootNavigator: true,
    side: .ltr,
    mainAxisMaxRatio: null,
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

/// A dialog with arbitrary content. Replaces `showDialog` + `AlertDialog` for
/// the cases [brandConfirm] cannot cover — the ones whose body is a form.
///
/// [builder] gets the dialog's own context, so `Navigator.pop(context, value)`
/// inside it returns from this future.
Future<T?> brandDialog<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  List<Widget> actions = const [],
  bool barrierDismissible = true,
}) => showFDialog<T>(
  context: context,
  useRootNavigator: true,
  barrierDismissible: barrierDismissible,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    style: style,
    // FDialog hands over the bare surface — the content inset is the caller's
    // job, and forui's own `insetPadding` is the margin from the screen edge.
    // The dialog shrinks to clear the keyboard, so a form taller than what
    // is left scrolls inside the card rather than spilling out under it.
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          builder(context),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            // Stacked rather than in a trailing row: the brand's buttons are
            // full-width pills, and a form dialog is narrow.
            for (final action in actions) ...[
              action,
              if (action != actions.last) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    ),
  ),
);

/// Blocking PIN prompt shared by the app lock gate and locked notes. Returns
/// true only when [verify] accepts the entered PIN.
Future<bool> promptForPin(
  BuildContext context,
  bool Function(String pin) verify, {
  String title = 'Enter PIN',
}) async {
  final controller = TextEditingController();
  String? error;

  final ok = await brandDialog<bool>(
    context,
    title: title,
    // Tapping outside must not dismiss a lock prompt.
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (_, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandField(
            controller: controller,
            autofocus: true,
            obscure: true,
            keyboardType: TextInputType.number,
            error: error,
          ),
          const SizedBox(height: 20),
          BrandButton(
            label: 'Unlock',
            onPressed: () {
              if (verify(controller.text)) {
                Navigator.pop(dialogContext, true);
              } else {
                setState(() => error = 'Incorrect PIN');
              }
            },
          ),
          const SizedBox(height: 8),
          BrandButton(
            label: 'Cancel',
            kind: BrandButtonKind.ghost,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
        ],
      ),
    ),
  );

  return ok == true;
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
    useRootNavigator: true,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      style: style,
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: context.muted),
              ),
            ],
            const SizedBox(height: 20),
            BrandButton(
              label: confirmLabel,
              kind: destructive
                  ? BrandButtonKind.danger
                  : BrandButtonKind.primary,
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
    0xFFFF6547,
    0xFF3BB273,
    0xFFF2A03D,
    0xFFE5484D,
    0xFF9A6DD7,
    0xFF3AAFB9,
    0xFFE86FA0,
    0xFF6C6C6C,
  ];

  const ColorPickerRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

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
              color: isSel
                  ? color.withValues(alpha: 0.18)
                  : context.brand.tint(0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSel ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: AppIcon(
              e.value,
              size: 20,
              color: isSel ? color : Theme.of(context).colorScheme.outline,
            ),
          ),
        );
      }).toList(),
    );
  }
}
