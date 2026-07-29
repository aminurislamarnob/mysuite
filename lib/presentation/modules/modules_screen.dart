import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';

class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  /// Icon and accent colour for each module, shared with onboarding.
  static (IconData, Color) metaFor(AppModule m) => _meta[m]!;

  static const _meta = <AppModule, (IconData, Color)>{
    AppModule.notes: (AppIcons.notes, AppColors.noteAccent),
    AppModule.medicine: (AppIcons.medicine, AppColors.medicineAccent),
    AppModule.habits: (AppIcons.habits, AppColors.habitAccent),
    AppModule.tasks: (AppIcons.tasks, AppColors.taskAccent),
    AppModule.expenses: (AppIcons.expenses, AppColors.expenseAccent),
    AppModule.focus: (AppIcons.focus, AppColors.focusAccent),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final enabled =
        AppModule.values.where(settings.isEnabled).toList();
    final disabled =
        AppModule.values.where((m) => !settings.isEnabled(m)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Modules')),
      body: enabled.isEmpty
          ? const EmptyState(
              icon: Icons.apps_outlined,
              title: 'Everything is switched off',
              message: 'Turn a module back on below to start using it.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                  children: [
                    for (var i = 0; i < enabled.length; i++)
                      Builder(builder: (context) {
                        final m = enabled[i];
                        final (icon, color) = _meta[m]!;
                        return _ModuleCard(
                          module: m,
                          icon: icon,
                          color: color,
                          tintIndex: i,
                          onTap: () => context.push(m.route),
                        );
                      }),
                  ],
                ),
                if (disabled.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  const SectionHeader('Switched off'),
                  ...disabled.map((m) {
                    final (icon, color) = _meta[m]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TintCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 4),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(icon, color: context.muted),
                          title: Text(m.label),
                          subtitle: Text(m.blurb,
                              style: const TextStyle(fontSize: 12)),
                          trailing: TextButton(
                            onPressed: () => ref
                                .read(settingsProvider.notifier)
                                .toggleModule(m, true),
                            style: TextButton.styleFrom(foregroundColor: color),
                            child: const Text('Turn on'),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}

class _ModuleCard extends ConsumerWidget {
  final AppModule module;
  final IconData icon;
  final Color color;
  final int tintIndex;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.module,
    required this.icon,
    required this.color,
    required this.tintIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      // Long-press still switches the module off, as before.
      onLongPress: () =>
          ref.read(settingsProvider.notifier).toggleModule(module, false),
      child: TintCard(
        tintIndex: tintIndex,
        onTap: onTap,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(module.label,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  module.blurb,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12, height: 1.3, color: context.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
