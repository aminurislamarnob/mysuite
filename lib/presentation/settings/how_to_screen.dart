import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../modules/modules_screen.dart';
import 'how_to_content.dart';

/// The short guides to the app, reached from Settings.
///
/// One collapsible card per guide keeps the page scannable: the header names
/// an area and says what it is for, the body lists the handful of steps that
/// cover most of what people do there. The strip at the top jumps to a card
/// and opens it, and a module's card ends with a way into that module — or a
/// way to switch it on, when it is off.
class HowToScreen extends ConsumerStatefulWidget {
  /// The [HowToGuide.id] to open on arrival. Unknown ids are ignored and the
  /// quick-start guide opens instead.
  final String? initialGuide;

  const HowToScreen({super.key, this.initialGuide});

  @override
  ConsumerState<HowToScreen> createState() => _HowToScreenState();
}

class _HowToScreenState extends ConsumerState<HowToScreen> {
  final Set<String> _open = {};
  final _keys = {for (final g in howToGuides) g.id: GlobalKey()};

  @override
  void initState() {
    super.initState();
    final initial = widget.initialGuide;
    final known = initial != null && _keys.containsKey(initial);
    _open.add(known ? initial : howToGuides.first.id);
    if (known) {
      // The card can only be scrolled to once it has been laid out.
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(initial));
    }
  }

  Duration get _motion => MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 220);

  void _toggle(String id) {
    setState(() => _open.contains(id) ? _open.remove(id) : _open.add(id));
  }

  /// Opens [id] and brings it to the top of the page.
  void _jump(String id) {
    setState(() => _open.add(id));
    // After the frame: the scroll target is the card's laid-out size, and the
    // body that was just opened is not part of it until then.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(id));
  }

  void _reveal(String id) {
    if (!mounted) return;
    final target = _keys[id]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target, duration: _motion, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return BrandScaffold(
      header: const BrandTopBar(
        title: 'How to use mySuite',
        leadingIcon: AppIcons.back,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Short guides for every part of the app. Tap a card to open '
                'it, or jump straight to one.',
                style: TextStyle(
                  color: context.muted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Full-bleed so the strip scrolls out under the page edge rather
            // than being cut off at the padding.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final (i, guide) in howToGuides.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Pill(
                      key: Key('howto-jump-${guide.id}'),
                      label: guide.label,
                      icon: guide.icon,
                      color: _accentFor(context, guide),
                      selected: _open.contains(guide.id),
                      onTap: () => _jump(guide.id),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final guide in howToGuides)
                    Padding(
                      // The scroll target, so a jump lands the card at the
                      // top of the page.
                      key: _keys[guide.id],
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GuideCard(
                        key: Key('howto-card-${guide.id}'),
                        guide: guide,
                        accent: _accentFor(context, guide),
                        open: _open.contains(guide.id),
                        enabled:
                            guide.module == null ||
                            settings.isEnabled(guide.module!),
                        motion: _motion,
                        onToggle: () => _toggle(guide.id),
                        onOpen: guide.module == null
                            ? null
                            : () => context.push(guide.module!.route),
                        onTurnOn: guide.module == null
                            ? null
                            : () => notifier.toggleModule(guide.module!, true),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A module guide wears its module's colour; an app-wide one wears the brand.
  static Color _accentFor(BuildContext context, HowToGuide guide) {
    final module = guide.module;
    return module == null
        ? Theme.of(context).colorScheme.primary
        : ModulesScreen.accentFor(context.brand, module);
  }
}

class _GuideCard extends StatelessWidget {
  final HowToGuide guide;
  final Color accent;
  final bool open;

  /// Whether the guide's module is switched on. Always true for a guide
  /// without a module.
  final bool enabled;

  final Duration motion;
  final VoidCallback onToggle;
  final VoidCallback? onOpen;
  final VoidCallback? onTurnOn;

  const _GuideCard({
    super.key,
    required this.guide,
    required this.accent,
    required this.open,
    required this.enabled,
    required this.motion,
    required this.onToggle,
    required this.onOpen,
    required this.onTurnOn,
  });

  @override
  Widget build(BuildContext context) {
    final muted = context.muted;
    final onAccent = context.brand.onAccent(accent);

    return TintCard(
      accent: accent,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandTappable(
            onPressed: onToggle,
            semanticsLabel: '${guide.title}, ${open ? 'collapse' : 'expand'}',
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(guide.icon, color: onAccent, size: 21),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                guide.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (!enabled) ...[
                              const SizedBox(width: 8),
                              _Badge('Off', color: muted),
                            ],
                          ],
                        ),
                        Text(
                          guide.tagline,
                          style: TextStyle(fontSize: 12.5, color: muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: motion,
                    child: AppIcon(
                      AppIcons.chevronDown,
                      size: 20,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: motion,
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? _GuideBody(
                    guide: guide,
                    accent: accent,
                    enabled: enabled,
                    onOpen: onOpen,
                    onTurnOn: onTurnOn,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _GuideBody extends StatelessWidget {
  final HowToGuide guide;
  final Color accent;
  final bool enabled;
  final VoidCallback? onOpen;
  final VoidCallback? onTurnOn;

  const _GuideBody({
    required this.guide,
    required this.accent,
    required this.enabled,
    required this.onOpen,
    required this.onTurnOn,
  });

  @override
  Widget build(BuildContext context) {
    final muted = context.muted;
    final onAccent = context.brand.onAccent(accent);
    final module = guide.module;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, step) in guide.steps.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == guide.steps.length - 1 ? 0 : 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: onAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          step.action,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.detail,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (guide.tips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'GOOD TO KNOW',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: muted,
              ),
            ),
            const SizedBox(height: 8),
            for (final (i, tip) in guide.tips.indexed)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == guide.tips.length - 1 ? 0 : 6,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: AppIcon(AppIcons.idea, size: 15, color: accent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 12.5, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (module != null) ...[
            const SizedBox(height: 14),
            // forui lays a button's label out in a plain Row, so a label
            // cannot wrap or shrink on its own. The FittedBox only ever
            // scales the pill down, and only once the card is narrower than
            // the label — a large text size on a small phone — so at every
            // ordinary size it draws at 1:1.
            if (enabled)
              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: BrandButton(
                    label: 'Open ${module.label}',
                    kind: BrandButtonKind.outline,
                    icon: AppIcons.chevronRight,
                    expand: false,
                    small: true,
                    onPressed: onOpen,
                  ),
                ),
              )
            else
              // A Wrap rather than a Row: when the two do not fit on one
              // line the button drops below the text instead of clipping.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    'Switched off in Settings.',
                    style: TextStyle(fontSize: 12.5, color: muted),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: BrandButton(
                      label: 'Turn on',
                      kind: BrandButtonKind.ghost,
                      expand: false,
                      small: true,
                      onPressed: onTurnOn,
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

/// A small outlined tag, for the "Off" mark on a switched-off module's card.
class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge(this.label, {required this.color});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      shape: StadiumBorder(
        side: BorderSide(color: color.withValues(alpha: 0.6)),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ),
  );
}
