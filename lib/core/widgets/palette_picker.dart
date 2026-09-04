import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// The row of colour swatches that picks the app's palette.
///
/// There is no separate preview: the screen behind this is built from the same
/// theme, so tapping a swatch recolours the card it sits in, the nav bar and
/// everything else under the finger. The app is the preview.
class PalettePicker extends ConsumerWidget {
  const PalettePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(settingsProvider.select((s) => s.palette));
    final notifier = ref.read(settingsProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final p in AppPalette.values)
          _Swatch(
            palette: p,
            selected: p == selected,
            onTap: () => notifier.setPalette(p),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hairline = context.brand.hairline;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: palette.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          // A 28px dot inside a 40px target: the dot stays a dot at any text
          // scale, while the tappable area still clears the 40px minimum.
          width: 40,
          height: 40,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: palette.swatch,
                shape: BoxShape.circle,
                border: Border.all(
                  // Selection reads as a ring in the text colour rather than
                  // a tick, so it stays legible on every swatch including the
                  // near-black aubergine.
                  color: selected ? onSurface : hairline,
                  width: selected ? 2.5 : 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
