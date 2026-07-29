import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand.dart';

/// Shared presentational widgets. Everything here reads its colours from the
/// active [Theme] so light, dark and high-contrast all stay legible.

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
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
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
              child: Icon(icon,
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
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
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
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
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
  final IconData icon;
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
              Icon(icon, size: 20, color: color),
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
                  child: Tooltip(
                    message: '${day.year}-${day.month}-${day.day}',
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
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: context.brand.hairline,
            color: over ? Theme.of(context).colorScheme.error : color,
            minHeight: 8,
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
    return SafeArea(
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
    );
  }
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
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

/// Icon picker backed by one of the token maps in `AppIcons`.
class IconPickerRow extends StatelessWidget {
  final Map<String, IconData> options;
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
            child: Icon(e.value,
                size: 20,
                color: isSel ? color : Theme.of(context).colorScheme.outline),
          ),
        );
      }).toList(),
    );
  }
}
