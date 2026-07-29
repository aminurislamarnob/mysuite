import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';

/// The signature pieces of the coral fitness identity.
///
/// Everything here reads its colours from the active [Theme] and the
/// [BrandColors] extension, so light, dark and high-contrast all stay legible
/// without any screen hardcoding a palette.

// ---------------------------------------------------------------------------
// Surfaces
// ---------------------------------------------------------------------------

/// The workhorse of the design: a large, softly rounded card on a barely-there
/// pastel fill, with no border and no shadow.
///
/// Pass [tintIndex] to rotate through the three brand pastels so a row of cards
/// does not read as one flat block, or [accent] to derive the fill from a
/// module colour instead.
class TintCard extends StatelessWidget {
  final Widget child;
  final int tintIndex;
  final Color? accent;
  final Color? fill;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const TintCard({
    super.key,
    required this.child,
    this.tintIndex = 0,
    this.accent,
    this.fill,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppRadii.tile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = context.brand;
    // High contrast collapses the tints to a flat canvas, so the card leans on
    // a real outline to stay separable.
    final flattened = brand.tints.toSet().length == 1;
    final background = fill ??
        (accent == null
            ? brand.tint(tintIndex)
            : (flattened
                ? brand.tint(0)
                : AppColors.wash(accent!, brightness: theme.brightness)));

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: flattened
          ? BorderSide(color: theme.colorScheme.onSurface, width: 1.2)
          : BorderSide.none,
    );

    return Material(
      color: background,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The thin outlined circle that holds the bell, close and settings glyphs in
/// the reference screens' top bars.
class CircleIconButton extends StatelessWidget {
  final HugeIconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;

  /// Fills the circle with [color] and inverts the glyph, for the one primary
  /// action in a bar.
  final bool filled;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 44,
    this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = color ?? theme.colorScheme.onSurface;

    final button = Material(
      color: filled ? tone : Colors.transparent,
      shape: CircleBorder(
        side: filled
            ? BorderSide.none
            : BorderSide(color: context.brand.hairline, width: 1.4),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: AppIcon(
            icon,
            size: size * 0.45,
            color: filled ? Colors.white : tone,
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// The centred title bar used on the detail screens: a close/back circle, a
/// bold centred title and an optional trailing circle.
class BrandTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final HugeIconData leadingIcon;
  final VoidCallback? onLeading;
  final HugeIconData? trailingIcon;
  final VoidCallback? onTrailing;
  final String? trailingTooltip;

  const BrandTopBar({
    super.key,
    required this.title,
    this.leadingIcon = AppIcons.close,
    this.onLeading,
    this.trailingIcon,
    this.onTrailing,
    this.trailingTooltip,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final pop = onLeading ?? () => Navigator.maybePop(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          children: [
            CircleIconButton(
                icon: leadingIcon, onPressed: pop, tooltip: 'Back', size: 40),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17),
              ),
            ),
            if (trailingIcon != null)
              CircleIconButton(
                icon: trailingIcon!,
                onPressed: onTrailing,
                tooltip: trailingTooltip,
                size: 40,
              )
            else
              const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

/// The home-screen header: round avatar, greeting stacked over the date, and a
/// trailing circle of actions.
class GreetingHeader extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final String initials;
  final List<Widget> actions;
  final VoidCallback? onAvatarTap;

  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.subtitle,
    this.initials = 'M',
    this.actions = const [],
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.coralSoft, AppColors.coral],
              ),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(greeting,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(subtitle,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}

/// The wide feature card at the top of the home screen: a pill label, a bold
/// two-line headline, a muted footnote and a decorative accent glyph.
class HeroBanner extends StatelessWidget {
  final String label;
  final String headline;
  final String footnote;
  final HugeIconData icon;
  final Color accent;
  final VoidCallback? onTap;

  const HeroBanner({
    super.key,
    required this.label,
    required this.headline,
    required this.footnote,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TintCard(
      accent: accent,
      radius: AppRadii.card,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Pill(label: label, color: accent),
                const SizedBox(height: 12),
                Text(
                  headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20, height: 1.25, letterSpacing: -0.4),
                ),
                const SizedBox(height: 8),
                Text(
                  footnote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: context.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          // The reference art is a photo bleeding off the card edge; a large
          // low-contrast glyph fills the same role without shipping assets.
          SizedBox(
            width: 108,
            height: 108,
            child: AppIcon(icon, size: 76, color: accent.withValues(alpha: 0.28)),
          ),
        ],
      ),
    );
  }
}

/// A rounded label chip. Used for the hero banner category and for filters.
class Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final HugeIconData? icon;
  final VoidCallback? onTap;

  const Pill({
    super.key,
    required this.label,
    required this.color,
    this.selected = false,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected ? color : context.brand.canvas;
    final foreground = selected ? Colors.white : color;
    return Material(
      color: background,
      shape: StadiumBorder(
        side: selected
            ? BorderSide.none
            : BorderSide(color: context.brand.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                AppIcon(icon!, size: 15, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of the "My Plans" cards: a coloured glyph over a bold label and a muted
/// value. Sized to sit in a fixed-height row.
class PlanCard extends StatelessWidget {
  final HugeIconData icon;
  final String label;
  final String value;
  final Color accent;
  final int tintIndex;
  final VoidCallback? onTap;

  const PlanCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.tintIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TintCard(
      tintIndex: tintIndex,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppIcon(icon, size: 28, color: accent),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: context.muted, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data display
// ---------------------------------------------------------------------------

/// The thick coral donut from the food-summary and running screens: a rounded
/// arc over a grey track, a dashed inner guide, and free-form centre content.
class ProgressRing extends StatelessWidget {
  /// 0..1. Values above 1 are clamped but recoloured to signal the overrun.
  final double value;
  final double size;
  final double thickness;
  final Color? color;
  final Widget? center;

  /// Draws the dashed inner circle from the reference design.
  final bool dashedGuide;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 180,
    this.thickness = 22,
    this.color,
    this.center,
    this.dashedGuide = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final over = value > 1.0;
    final tone =
        over ? theme.colorScheme.error : (color ?? theme.colorScheme.primary);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        builder: (context, animated, child) {
          return CustomPaint(
            painter: _RingPainter(
              value: animated,
              color: tone,
              track: context.brand.hairline,
              thickness: thickness,
              dashedGuide: dashedGuide,
            ),
            child: child,
          );
        },
        child: center == null
            ? null
            : Center(
                child: Padding(
                  padding: EdgeInsets.all(thickness + 12),
                  child: center,
                ),
              ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  final double thickness;
  final bool dashedGuide;

  const _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.thickness,
    required this.dashedGuide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - thickness) / 2;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawCircle(centre, radius, base);

    if (value > 0) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, -math.pi / 2, value * 2 * math.pi, false, arc);
    }

    if (dashedGuide) {
      final guideRadius = radius - thickness / 2 - 10;
      if (guideRadius > 8) {
        final dash = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.45);
        // 60 short dashes reads as the fine dotted guide in the reference at
        // any ring size.
        const segments = 60;
        const step = 2 * math.pi / segments;
        for (var i = 0; i < segments; i++) {
          final from = i * step;
          canvas.drawArc(
            Rect.fromCircle(center: centre, radius: guideRadius),
            from,
            step * 0.5,
            false,
            dash,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      old.thickness != thickness ||
      old.dashedGuide != dashedGuide;
}

/// The smoothed area chart under "Activities": a soft spline over faint
/// gridlines, with an optional highlighted point and a drop line.
class SplineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final int? highlight;
  final double height;

  /// Formats the four axis ticks. Defaults to whole numbers.
  final String Function(double)? formatTick;

  const SplineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    this.highlight,
    this.height = 190,
    this.formatTick,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return SizedBox(height: height);
    return SizedBox(
      height: height,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0, end: 1),
        builder: (context, t, _) => CustomPaint(
          size: Size.infinite,
          painter: _SplinePainter(
            values: values,
            labels: labels,
            color: color,
            grid: context.brand.hairline,
            labelColor: context.muted,
            highlight: highlight,
            progress: t,
            formatTick: formatTick ?? (v) => v.round().toString(),
            textDirection: Directionality.of(context),
          ),
        ),
      ),
    );
  }
}

class _SplinePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final Color grid;
  final Color labelColor;
  final int? highlight;
  final double progress;
  final String Function(double) formatTick;
  final TextDirection textDirection;

  const _SplinePainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.grid,
    required this.labelColor,
    required this.highlight,
    required this.progress,
    required this.formatTick,
    required this.textDirection,
  });

  static const _axisWidth = 34.0;
  static const _labelHeight = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      _axisWidth,
      6,
      size.width,
      size.height - _labelHeight,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    var min = values.reduce(math.min);
    var max = values.reduce(math.max);
    if (max - min < 1e-9) {
      // A flat series would divide by zero; give it an arbitrary band so the
      // line lands in the middle of the plot.
      max = min + 1;
    }
    // Breathing room above and below so the curve never touches the frame.
    final pad = (max - min) * 0.15;
    min -= pad;
    max += pad;

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final t = i / 3;
      final y = plot.bottom - t * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _text(
        canvas,
        formatTick(min + t * (max - min)),
        Offset(0, y - 8),
        labelColor,
        11,
      );
    }

    Offset pointAt(int i) {
      final x = values.length == 1
          ? plot.center.dx
          : plot.left + plot.width * (i / (values.length - 1));
      final y = plot.bottom -
          plot.height * ((values[i] - min) / (max - min)).clamp(0.0, 1.0);
      return Offset(x, y);
    }

    final points = [for (var i = 0; i < values.length; i++) pointAt(i)];

    // Vertical separators, one per sample, matching the reference grid.
    for (final p in points) {
      canvas.drawLine(Offset(p.dx, plot.top), Offset(p.dx, plot.bottom),
          gridPaint..color = grid);
    }

    final path = _spline(points);

    // The fill is the curve closed down to the baseline.
    final fill = Path.from(path)
      ..lineTo(points.last.dx, plot.bottom)
      ..lineTo(points.first.dx, plot.bottom)
      ..close();
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(
        plot.left, plot.top, plot.left + plot.width * progress, plot.bottom));
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.02)],
        ).createShader(plot),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    canvas.restore();

    // Day labels under each sample.
    for (var i = 0; i < points.length && i < labels.length; i++) {
      _text(canvas, labels[i], Offset(points[i].dx - 12, plot.bottom + 5),
          labelColor, 12);
    }

    final index = highlight;
    if (index != null && index >= 0 && index < points.length && progress > 0.99) {
      final p = points[index];
      canvas.drawLine(
        p,
        Offset(p.dx, plot.bottom),
        Paint()
          ..color = labelColor.withValues(alpha: 0.5)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(p, 8.5, Paint()..color = color.withValues(alpha: 0.25));
      canvas.drawCircle(p, 3.5, Paint()..color = color);
    }
  }

  /// A Catmull-Rom spline through [points], converted to cubic Béziers.
  Path _spline(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length < 3) {
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      return path;
    }
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[0] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;
      path.cubicTo(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  void _text(
      Canvas canvas, String value, Offset at, Color color, double size) {
    TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(color: color, fontSize: size),
      ),
      textDirection: textDirection,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(_SplinePainter old) =>
      old.progress != progress ||
      old.highlight != highlight ||
      !listEquals(old.values, values) ||
      old.color != color;

  static bool listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// The horizontal date selector from the food-summary screen: rounded day cells
/// with the selected one filled in coral.
class DayStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  /// How many days to show, ending [trailingDays] after today.
  final int days;
  final int trailingDays;

  const DayStrip({
    super.key,
    required this.selected,
    required this.onSelected,
    this.days = 7,
    this.trailingDays = 3,
  });

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: days - 1 - trailingDays));

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: days,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final day = start.add(Duration(days: i));
          final isSelected = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          return _DayCell(
            day: day,
            weekday: _weekdays[day.weekday - 1],
            selected: isSelected,
            onTap: () => onSelected(day),
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final String weekday;
  final bool selected;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.weekday,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        selected ? Colors.white : theme.colorScheme.onSurface;
    return Semantics(
      selected: selected,
      button: true,
      label: '${day.day} $weekday',
      child: Material(
        color: selected ? theme.colorScheme.primary : context.brand.tint(0),
        borderRadius: BorderRadius.circular(AppRadii.field),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.day.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  weekday,
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.9)
                        : context.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The metric trio under the running ring: a coral glyph over a bold value and
/// a muted caption.
class MetricColumn extends StatelessWidget {
  final HugeIconData icon;
  final String value;
  final String caption;
  final Color? color;

  const MetricColumn({
    super.key,
    required this.icon,
    required this.value,
    required this.caption,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = color ?? theme.colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, size: 28, color: tone),
        const SizedBox(height: 14),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(fontSize: 16)),
        Text(caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: context.muted, fontSize: 13)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation
// ---------------------------------------------------------------------------

/// The bottom bar from the reference screens: a white surface whose top edge
/// sweeps up at the sides and dips around the centre action button.
class CurvedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final List<CurvedNavItem> items;

  /// The circular action that overlaps the notch.
  final Widget centerAction;

  const CurvedNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.items,
    required this.centerAction,
  });

  /// How far the action button sits above the bar's nominal top edge.
  static const overlap = 26.0;
  static const barHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final split = (items.length / 2).ceil();

    return SizedBox(
      height: barHeight + overlap + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            top: overlap,
            child: CustomPaint(
              painter: _NavBarPainter(
                color: theme.scaffoldBackgroundColor,
                edge: context.brand.hairline,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset,
            height: barHeight,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  // A gap in the middle of the row keeps the two halves clear
                  // of the centre action.
                  if (i == split) const SizedBox(width: 76),
                  Expanded(
                    child: _NavButton(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: bottomInset + barHeight - 24,
            child: centerAction,
          ),
        ],
      ),
    );
  }
}

/// One destination in a [CurvedNavBar].
@immutable
class CurvedNavItem {
  final HugeIconData icon;
  final HugeIconData? selectedIcon;
  final String label;

  const CurvedNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });
}

class _NavButton extends StatelessWidget {
  final CurvedNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = selected ? theme.colorScheme.primary : context.muted;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: InkResponse(
          onTap: onTap,
          radius: 32,
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  selected ? (item.selectedIcon ?? item.icon) : item.icon,
                  color: tone,
                  size: 24,
                ),
                const SizedBox(height: 4),
                // A dot rather than a label keeps the bar as sparse as the
                // reference while still marking the active tab.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 16 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final Color color;
  final Color edge;

  const _NavBarPainter({required this.color, required this.edge});

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.width / 2;
    // Half-width of the notch, plus the height of the side sweep.
    const notch = 42.0;
    const lift = 18.0;

    // Only the top edge is ever stroked, so it is built on its own and the
    // filled shape closes off it. Stroking the closed path instead would draw
    // a hairline down the screen sides and along the bottom.
    final top = Path()
      ..moveTo(0, lift)
      // The edge rises from the corners towards the notch shoulders.
      ..quadraticBezierTo(centre * 0.5, 0, centre - notch - 12, 0)
      // Then dips under the action button.
      ..cubicTo(centre - notch + 6, 0, centre - notch + 4, notch * 0.72,
          centre, notch * 0.72)
      ..cubicTo(centre + notch - 4, notch * 0.72, centre + notch - 6, 0,
          centre + notch + 12, 0)
      ..quadraticBezierTo(size.width - centre * 0.5, 0, size.width, lift);

    final fill = Path.from(top)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawShadow(fill, Colors.black.withValues(alpha: 0.28), 6, false);
    canvas.drawPath(fill, Paint()..color = color);
    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = edge,
    );
  }

  @override
  bool shouldRepaint(_NavBarPainter old) =>
      old.color != color || old.edge != edge;
}
