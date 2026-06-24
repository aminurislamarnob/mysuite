import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/modules.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../state/settings_controller.dart';

/// First-run flow (spec 6.A): pick a theme, choose which modules to enable,
/// then land on the dashboard. Data import & PIN setup are Phase 2.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Set<ModuleId> _selected = ModuleId.values.toSet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              IconBadge(LucideIcons.sparkles,
                  color: context.colors.primary, size: 56),
              const SizedBox(height: 20),
              Text('Welcome to mySuite',
                  style: context.text.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'Your day, in one place. Pick the tools you want — turn the rest on anytime.',
                style: context.text.bodyMedium?.copyWith(color: context.muted),
              ),
              const SizedBox(height: 24),
              Text('Which tools do you want?',
                  style: context.text.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: kModules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final m = kModules[i];
                    final on = _selected.contains(m.id);
                    return AppCard(
                      onTap: () => setState(() {
                        on ? _selected.remove(m.id) : _selected.add(m.id);
                      }),
                      child: Row(
                        children: [
                          IconBadge(m.icon, color: m.accent),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.label,
                                    style: context.text.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700)),
                                Text(m.tagline,
                                    style: context.text.bodySmall
                                        ?.copyWith(color: context.muted)),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: on,
                            onChanged: (v) => setState(() {
                              v == true
                                  ? _selected.add(m.id)
                                  : _selected.remove(m.id);
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context
                      .read<SettingsController>()
                      .completeOnboarding(_selected),
                  child: Text(
                      'Get started${_selected.isEmpty ? '' : ' with ${_selected.length} tools'}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
