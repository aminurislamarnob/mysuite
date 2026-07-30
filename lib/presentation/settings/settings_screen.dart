import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../core/services/export_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/security_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final security = ref.read(securityServiceProvider);

    return BrandScaffold(
      header: const BrandTopBar(title: 'Settings', leadingIcon: null),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
        children: [
          const SectionHeader('Modules'),
          TintCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: AppModule.values
                  .map(
                    (m) => BrandSwitchTile(
                      title: m.label,
                      subtitle: m.blurb,
                      value: settings.isEnabled(m),
                      onChanged: (v) => notifier.toggleModule(m, v),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Appearance'),
          TintCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                BrandTile(
                  leading: const AppIcon(AppIcons.themeMode),
                  title: const Text('Theme'),
                  trailing: BrandSegmented<ThemeMode>(
                    options: const {
                      ThemeMode.light: 'Light',
                      ThemeMode.system: 'Auto',
                      ThemeMode.dark: 'Dark',
                    },
                    selected: settings.themeMode,
                    onSelected: notifier.setThemeMode,
                  ),
                ),
                BrandSwitchTile(
                  leading: const AppIcon(AppIcons.highContrast),
                  title: 'High contrast',
                  value: settings.highContrast,
                  onChanged: notifier.setHighContrast,
                ),
                BrandSwitchTile(
                  leading: const AppIcon(AppIcons.compact),
                  title: 'Compact density',
                  value: settings.compactDensity,
                  onChanged: notifier.setCompactDensity,
                ),
                BrandSwitchTile(
                  leading: const AppIcon(AppIcons.reduceMotion),
                  title: 'Reduce motion',
                  value: settings.reduceMotion,
                  onChanged: notifier.setReduceMotion,
                ),
                BrandTile(
                  leading: const AppIcon(AppIcons.textSize),
                  title: const Text('Text size'),
                  subtitle: Text('${(settings.textScale * 100).round()}%'),
                  trailing: SizedBox(
                    width: 150,
                    child: BrandSlider(
                      value: settings.textScale,
                      min: 0.85,
                      max: 1.6,
                      divisions: 15,
                      onChanged: notifier.setTextScale,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Language & region'),
          TintCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                BrandTile(
                  leading: const AppIcon(AppIcons.language),
                  title: const Text('Language'),
                  subtitle: Text(settings.locale == 'bn' ? 'বাংলা' : 'English'),
                  trailing: BrandSegmented<String>(
                    options: const {'en': 'EN', 'bn': 'বাং'},
                    selected: settings.locale,
                    onSelected: notifier.setLocale,
                  ),
                ),
                BrandTile(
                  leading: const AppIcon(AppIcons.cash),
                  title: const Text('Currency symbol'),
                  subtitle: Text(settings.currencySymbol),
                  onTap: () => _pickCurrency(context, notifier),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Notifications'),
          TintCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                BrandTile(
                  leading: const AppIcon(AppIcons.notificationsActive),
                  title: const Text('Allow notifications'),
                  subtitle: const Text(
                    'Medicine reminders always override quiet hours',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const AppIcon(AppIcons.chevronRight),
                  onTap: () async {
                    final granted = await ref
                        .read(notificationServiceProvider)
                        .requestPermissions();
                    if (context.mounted) {
                      brandToast(
                        context,
                        granted
                            ? 'Notifications enabled.'
                            : 'Permission denied — enable it in system settings.',
                      );
                    }
                  },
                ),
                BrandSwitchTile(
                  leading: const AppIcon(AppIcons.sleep),
                  title: 'Quiet hours',
                  subtitle:
                      '${Fmt.minutesOfDay(settings.dndStartMinutes)} — '
                      '${Fmt.minutesOfDay(settings.dndEndMinutes)}',
                  value: settings.dndEnabled,
                  onChanged: (v) => notifier.setDnd(v),
                ),
                if (settings.dndEnabled)
                  Row(
                    children: [
                      Expanded(
                        child: BrandTile(
                          title: const Text(
                            'From',
                            style: TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            Fmt.minutesOfDay(settings.dndStartMinutes),
                          ),
                          onTap: () async {
                            final t = await _pickTime(
                              context,
                              settings.dndStartMinutes,
                            );
                            if (t != null) {
                              notifier.setDnd(
                                true,
                                start: t,
                                end: settings.dndEndMinutes,
                              );
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: BrandTile(
                          title: const Text(
                            'To',
                            style: TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            Fmt.minutesOfDay(settings.dndEndMinutes),
                          ),
                          onTap: () async {
                            final t = await _pickTime(
                              context,
                              settings.dndEndMinutes,
                            );
                            if (t != null) {
                              notifier.setDnd(
                                true,
                                start: settings.dndStartMinutes,
                                end: t,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Security'),
          TintCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                BrandSwitchTile(
                  leading: const AppIcon(AppIcons.lock),
                  title: 'Lock the app',
                  subtitle: 'Biometric or PIN on launch',
                  value: settings.appLockEnabled,
                  onChanged: (v) async {
                    if (v &&
                        !await security.canUseBiometrics() &&
                        !security.hasPin) {
                      if (context.mounted) {
                        final set = await _setPin(context, security);
                        if (!set) return;
                      }
                    }
                    notifier.setAppLock(v);
                  },
                ),
                BrandTile(
                  leading: const AppIcon(AppIcons.pin),
                  title: Text(security.hasPin ? 'Change PIN' : 'Set a PIN'),
                  trailing: security.hasPin
                      ? CircleIconButton(
                          icon: AppIcons.delete,
                          tooltip: 'Remove PIN',
                          size: 36,
                          onPressed: () async {
                            await security.clearPin();
                            if (context.mounted) {
                              brandToast(context, 'PIN removed.');
                            }
                          },
                        )
                      : const AppIcon(AppIcons.chevronRight),
                  onTap: () => _setPin(context, security),
                ),
                BrandTile(
                  leading: const AppIcon(AppIcons.focus),
                  title: const Text('Auto-lock after'),
                  subtitle: Text('${settings.autoLockMinutes} minutes'),
                  onTap: () => _pickAutoLock(context, notifier),
                ),
                BrandAccordion(
                  leading: AppIcons.modules,
                  title: 'Lock individual modules',
                  child: Column(
                    children: AppModule.values
                        .map(
                          (m) => BrandSwitchTile(
                            title: m.label,
                            value: settings.lockedModules.contains(m),
                            onChanged: (v) => notifier.toggleModuleLock(m, v),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Data'),
          TintCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _exportTile(
                  context,
                  ref,
                  icon: AppIcons.backup,
                  title: 'Full backup (JSON)',
                  subtitle: 'Everything, restorable',
                  build: (e) => e.fullJsonBackup(),
                ),
                _exportTile(
                  context,
                  ref,
                  icon: AppIcons.checklist,
                  title: 'Tasks (CSV)',
                  build: (e) => e.tasksCsv(),
                ),
                _exportTile(
                  context,
                  ref,
                  icon: AppIcons.expenses,
                  title: 'Transactions (CSV)',
                  build: (e) => e.expensesCsv(),
                ),
                _exportTile(
                  context,
                  ref,
                  icon: AppIcons.medicine,
                  title: 'Medicine log (CSV)',
                  build: (e) => e.medicineCsv(),
                ),
                _exportTile(
                  context,
                  ref,
                  icon: AppIcons.habits,
                  title: 'Habit log (CSV)',
                  build: (e) => e.habitsCsv(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('About'),
          TintCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const BrandTile(
                  leading: AppIcon(AppIcons.info),
                  title: Text('mySuite'),
                  subtitle: Text('Version 1.0.0 · offline-first'),
                ),
                BrandTile(
                  leading: const AppIcon(AppIcons.notificationsOff),
                  title: const Text('Clear all scheduled reminders'),
                  onTap: () async {
                    await ref.read(notificationServiceProvider).cancelAll();
                    if (context.mounted) {
                      brandToast(context, 'Reminders cleared.');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportTile(
    BuildContext context,
    WidgetRef ref, {
    required HugeIconData icon,
    required String title,
    String? subtitle,
    required Future Function(ExportService) build,
  }) {
    return BrandTile(
      leading: AppIcon(icon),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const AppIcon(AppIcons.share, size: 18),
      onTap: () async {
        final service = ref.read(exportServiceProvider);
        try {
          final file = await build(service);
          await service.shareFile(file);
        } on Exception catch (e) {
          if (context.mounted) {
            brandToast(context, 'Export failed: $e');
          }
        }
      },
    );
  }

  Future<int?> _pickTime(BuildContext context, int current) =>
      brandTimePicker(context, initialMinutes: current, title: 'Quiet hours');

  Future<void> _pickCurrency(
    BuildContext context,
    SettingsNotifier notifier,
  ) async {
    const options = ['৳', '\$', '€', '₹', '£', '¥'];
    final picked = await brandSheet<String>(
      context: context,
      builder: (_) => SheetScaffold(
        title: 'Currency symbol',
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options
              .map(
                (s) => Pill(
                  label: s,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => Navigator.pop(context, s),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked != null) notifier.setCurrencySymbol(picked);
  }

  Future<void> _pickAutoLock(
    BuildContext context,
    SettingsNotifier notifier,
  ) async {
    final picked = await brandSheet<int>(
      context: context,
      builder: (_) => SheetScaffold(
        title: 'Auto-lock after',
        child: Column(
          children: [0, 1, 5, 15, 30]
              .map(
                (m) => BrandTile(
                  title: Text(m == 0 ? 'Immediately' : '$m minutes'),
                  onTap: () => Navigator.pop(context, m),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked != null) notifier.setAutoLockMinutes(picked);
  }

  Future<bool> _setPin(BuildContext context, SecurityService security) async {
    final controller = TextEditingController();
    final confirm = TextEditingController();
    String? error;

    final result = await showFDialog<bool>(
      context: context,
      builder: (_, style, animation) => StatefulBuilder(
        builder: (context, setState) => FDialog(
          animation: animation,
          style: style,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Set a PIN', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              BrandField(
                controller: controller,
                label: 'New PIN',
                autofocus: true,
                obscure: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              BrandField(
                controller: confirm,
                label: 'Confirm PIN',
                helper: error,
                obscure: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              BrandButton(
                label: 'Save',
                onPressed: () {
                  if (controller.text.length < 4) {
                    setState(() => error = 'Use at least 4 digits');
                    return;
                  }
                  if (controller.text != confirm.text) {
                    setState(() => error = 'PINs do not match');
                    return;
                  }
                  Navigator.pop(context, true);
                },
              ),
              const SizedBox(height: 8),
              BrandButton(
                label: 'Cancel',
                kind: BrandButtonKind.ghost,
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      await security.setPin(controller.text);
      if (context.mounted) {
        brandToast(context, 'PIN saved.');
      }
      return true;
    }
    return false;
  }
}

/// Colour reference kept close to the settings screen so accent previews and
/// the module list stay in sync with the design tokens.
const moduleAccent = <AppModule, Color>{
  AppModule.notes: AppColors.noteAccent,
  AppModule.medicine: AppColors.medicineAccent,
  AppModule.habits: AppColors.habitAccent,
  AppModule.tasks: AppColors.taskAccent,
  AppModule.expenses: AppColors.expenseAccent,
  AppModule.focus: AppColors.focusAccent,
};
