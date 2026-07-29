import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/export_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/security_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final security = ref.read(securityServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
        children: [
          const SectionHeader('Modules'),
          Card(
            child: Column(
              children: AppModule.values
                  .map((m) => SwitchListTile(
                        title: Text(m.label),
                        subtitle: Text(m.blurb,
                            style: const TextStyle(fontSize: 11)),
                        value: settings.isEnabled(m),
                        onChanged: (v) => notifier.toggleModule(m, v),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('Theme'),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined, size: 16)),
                      ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_outlined, size: 16)),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined, size: 16)),
                    ],
                    selected: {settings.themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => notifier.setThemeMode(s.first),
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.contrast),
                  title: const Text('High contrast'),
                  value: settings.highContrast,
                  onChanged: notifier.setHighContrast,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.density_small),
                  title: const Text('Compact density'),
                  value: settings.compactDensity,
                  onChanged: notifier.setCompactDensity,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.motion_photos_off_outlined),
                  title: const Text('Reduce motion'),
                  value: settings.reduceMotion,
                  onChanged: notifier.setReduceMotion,
                ),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Text size'),
                  subtitle: Slider(
                    value: settings.textScale,
                    min: 0.85,
                    max: 1.6,
                    divisions: 15,
                    label: '${(settings.textScale * 100).round()}%',
                    onChanged: notifier.setTextScale,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Language & region'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle:
                      Text(settings.locale == 'bn' ? 'বাংলা' : 'English'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('EN')),
                      ButtonSegment(value: 'bn', label: Text('বাং')),
                    ],
                    selected: {settings.locale},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => notifier.setLocale(s.first),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Currency symbol'),
                  subtitle: Text(settings.currencySymbol),
                  onTap: () => _pickCurrency(context, notifier),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Allow notifications'),
                  subtitle: const Text(
                      'Medicine reminders always override quiet hours',
                      style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final granted = await ref
                        .read(notificationServiceProvider)
                        .requestPermissions();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(granted
                            ? 'Notifications enabled.'
                            : 'Permission denied — enable it in system settings.'),
                      ));
                    }
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.bedtime_outlined),
                  title: const Text('Quiet hours'),
                  subtitle: Text(
                    '${Fmt.minutesOfDay(settings.dndStartMinutes)} — '
                    '${Fmt.minutesOfDay(settings.dndEndMinutes)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  value: settings.dndEnabled,
                  onChanged: (v) => notifier.setDnd(v),
                ),
                if (settings.dndEnabled)
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('From',
                              style: TextStyle(fontSize: 12)),
                          subtitle:
                              Text(Fmt.minutesOfDay(settings.dndStartMinutes)),
                          onTap: () async {
                            final t = await _pickTime(
                                context, settings.dndStartMinutes);
                            if (t != null) {
                              notifier.setDnd(true,
                                  start: t, end: settings.dndEndMinutes);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title:
                              const Text('To', style: TextStyle(fontSize: 12)),
                          subtitle:
                              Text(Fmt.minutesOfDay(settings.dndEndMinutes)),
                          onTap: () async {
                            final t = await _pickTime(
                                context, settings.dndEndMinutes);
                            if (t != null) {
                              notifier.setDnd(true,
                                  start: settings.dndStartMinutes, end: t);
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
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.lock_outline),
                  title: const Text('Lock the app'),
                  subtitle: const Text('Biometric or PIN on launch',
                      style: TextStyle(fontSize: 11)),
                  value: settings.appLockEnabled,
                  onChanged: (v) async {
                    if (v && !await security.canUseBiometrics() &&
                        !security.hasPin) {
                      if (context.mounted) {
                        final set = await _setPin(context, security);
                        if (!set) return;
                      }
                    }
                    notifier.setAppLock(v);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: Text(security.hasPin ? 'Change PIN' : 'Set a PIN'),
                  trailing: security.hasPin
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await security.clearPin();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('PIN removed.')),
                              );
                            }
                          },
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => _setPin(context, security),
                ),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Auto-lock after'),
                  subtitle: Text('${settings.autoLockMinutes} minutes'),
                  onTap: () => _pickAutoLock(context, notifier),
                ),
                ExpansionTile(
                  leading: const Icon(Icons.folder_special_outlined),
                  title: const Text('Lock individual modules'),
                  children: AppModule.values
                      .map((m) => SwitchListTile(
                            title: Text(m.label),
                            value: settings.lockedModules.contains(m),
                            onChanged: (v) => notifier.toggleModuleLock(m, v),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Data'),
          Card(
            child: Column(
              children: [
                _exportTile(
                  context,
                  ref,
                  icon: Icons.backup_outlined,
                  title: 'Full backup (JSON)',
                  subtitle: 'Everything, restorable',
                  build: (e) => e.fullJsonBackup(),
                ),
                _exportTile(
                  context,
                  ref,
                  icon: Icons.checklist_outlined,
                  title: 'Tasks (CSV)',
                  build: (e) => e.tasksCsv(),
                ),
                _exportTile(
                  context,
                  ref,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Transactions (CSV)',
                  build: (e) => e.expensesCsv(),
                ),
                _exportTile(
                  context,
                  ref,
                  icon: Icons.medication_outlined,
                  title: 'Medicine log (CSV)',
                  build: (e) => e.medicineCsv(),
                ),
                _exportTile(
                  context,
                  ref,
                  icon: Icons.local_cafe_outlined,
                  title: 'Habit log (CSV)',
                  build: (e) => e.habitsCsv(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('mySuite'),
                  subtitle: Text('Version 1.0.0 · offline-first'),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_paused_outlined),
                  title: const Text('Clear all scheduled reminders'),
                  onTap: () async {
                    await ref.read(notificationServiceProvider).cancelAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminders cleared.')),
                      );
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
    required IconData icon,
    required String title,
    String? subtitle,
    required Future Function(ExportService) build,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.ios_share, size: 18),
      onTap: () async {
        final service = ref.read(exportServiceProvider);
        try {
          final file = await build(service);
          await service.shareFile(file);
        } on Exception catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Export failed: $e')));
          }
        }
      },
    );
  }

  Future<int?> _pickTime(BuildContext context, int current) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  Future<void> _pickCurrency(
      BuildContext context, SettingsNotifier notifier) async {
    const options = ['৳', '\$', '€', '₹', '£', '¥'];
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SheetScaffold(
        title: 'Currency symbol',
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options
              .map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 18)),
                    onPressed: () => Navigator.pop(context, s),
                  ))
              .toList(),
        ),
      ),
    );
    if (picked != null) notifier.setCurrencySymbol(picked);
  }

  Future<void> _pickAutoLock(
      BuildContext context, SettingsNotifier notifier) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => SheetScaffold(
        title: 'Auto-lock after',
        child: Column(
          children: [0, 1, 5, 15, 30]
              .map((m) => ListTile(
                    title: Text(m == 0 ? 'Immediately' : '$m minutes'),
                    onTap: () => Navigator.pop(context, m),
                  ))
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

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set a PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'New PIN'),
              ),
              TextField(
                controller: confirm,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                    labelText: 'Confirm PIN', errorText: error),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await security.setPin(controller.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN saved.')),
        );
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
