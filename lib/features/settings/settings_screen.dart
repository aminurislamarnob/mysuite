import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/modules.dart';
import '../../core/theme/app_theme.dart';
import '../../state/settings_controller.dart';
import '../../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _accents = [
    Color(0xFF5B6CFF),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          const SectionHeader('Appearance', icon: LucideIcons.palette),
          AppCard(
            child: Column(
              children: [
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(LucideIcons.sun)),
                    ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Auto'),
                        icon: Icon(LucideIcons.smartphone)),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(LucideIcons.moon)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) =>
                      settings.setThemeMode(s.first),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Accent', style: context.text.bodyMedium),
                    const Spacer(),
                    for (final c in _accents)
                      GestureDetector(
                        onTap: () => settings.setAccent(c),
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: settings.accent.toARGB32() == c.toARGB32()
                                  ? context.colors.onSurface
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: settings.accent.toARGB32() == c.toARGB32()
                              ? const Icon(LucideIcons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader('Modules', icon: LucideIcons.layoutGrid),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final m in kModules)
                  SwitchListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    secondary: IconBadge(m.icon, color: m.accent, size: 36),
                    title: Text(m.label,
                        style: context.text.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text(m.tagline,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.muted)),
                    value: settings.isEnabled(m.id),
                    onChanged: (v) => settings.toggleModule(m.id, v),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader('About', icon: LucideIcons.info),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(LucideIcons.sparkles,
                        color: context.colors.primary, size: 40),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('mySuite',
                            style: context.text.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        Text('Version 1.0.0 · Your day, in one place.',
                            style: context.text.bodySmall
                                ?.copyWith(color: context.muted)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Offline-first, privacy-focused productivity & wellness suite. '
                  'Notes, Medicine, Habits, Tasks, Expenses and Focus — all in one app.',
                  style: context.text.bodySmall?.copyWith(color: context.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
