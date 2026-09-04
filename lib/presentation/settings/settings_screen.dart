import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/people/people_repository.dart';
import '../../core/people/person_avatar.dart';
import '../../core/services/export_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/security_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/palette_picker.dart';
import 'people_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final security = ref.read(securityServiceProvider);
    // Watched, not read: the PIN rows relabel the moment one is saved.
    final hasPin = ref.watch(pinStatusProvider);

    return BrandScaffold(
      header: const BrandTopBar(title: 'Settings', leadingIcon: null),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
        children: [
          const _ProfileCard(),
          const SizedBox(height: 24),
          const SectionHeader('Modules'),
          TintCard(
            padding: EdgeInsets.zero,
            child: TileGroup(
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
          const SectionHeader('People'),
          TintCard(
            padding: EdgeInsets.zero,
            child: BrandTile(
              leading: const AppIcon(AppIcons.people),
              title: const Text('Household & contacts'),
              subtitle: const Text(
                'Medicine profiles, who an expense was for, who owes what',
              ),
              trailing: const AppIcon(AppIcons.chevronRight),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PeopleScreen())),
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader('Appearance'),
          TintCard(
            padding: EdgeInsets.zero,
            child: TileGroup(
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
                BrandTile(
                  leading: const AppIcon(AppIcons.palette),
                  title: const Text('Palette'),
                  trailing: const PalettePicker(),
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
            child: TileGroup(
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
            child: TileGroup(
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
            child: TileGroup(
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
                        final set = await _setPin(context, ref);
                        if (!set) return;
                      }
                    }
                    notifier.setAppLock(v);
                  },
                ),
                BrandTile(
                  leading: const AppIcon(AppIcons.pin),
                  title: Text(hasPin ? 'Change PIN' : 'Set a PIN'),
                  trailing: hasPin
                      ? CircleIconButton(
                          icon: AppIcons.delete,
                          tooltip: 'Remove PIN',
                          size: 36,
                          onPressed: () async {
                            await ref.read(pinStatusProvider.notifier).clear();
                            if (context.mounted) {
                              brandToast(context, 'PIN removed.');
                            }
                          },
                        )
                      : const AppIcon(AppIcons.chevronRight),
                  onTap: () => _setPin(context, ref),
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
                  child: TileGroup(
                    children: AppModule.values
                        .map(
                          (m) => BrandSwitchTile(
                            title: m.label,
                            value: settings.lockedModules.contains(m),
                            onChanged: (v) async {
                              // A lock with no way to authenticate is no
                              // lock at all — set a PIN first.
                              if (v &&
                                  !await security.canUseBiometrics() &&
                                  !security.hasPin) {
                                if (context.mounted) {
                                  final set = await _setPin(context, ref);
                                  if (!set) return;
                                }
                              }
                              notifier.toggleModuleLock(m, v);
                            },
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
            child: TileGroup(
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
            child: TileGroup(
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
        child: TileColumn(
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

  Future<bool> _setPin(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirm = TextEditingController();
    String? lengthError;
    String? matchError;

    // The buttons live in the body rather than in `actions` because they need
    // the StatefulBuilder's setState to put the validation message on a field.
    final result = await brandDialog<bool>(
      context,
      title: 'Set a PIN',
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrandField(
              controller: controller,
              label: 'New PIN',
              error: lengthError,
              autofocus: true,
              obscure: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            BrandField(
              controller: confirm,
              label: 'Confirm PIN',
              error: matchError,
              obscure: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            BrandButton(
              label: 'Save',
              onPressed: () {
                final short = controller.text.length < 4;
                final mismatch = !short && controller.text != confirm.text;
                if (short || mismatch) {
                  setState(() {
                    lengthError = short ? 'Use at least 4 digits' : null;
                    matchError = mismatch ? 'PINs do not match' : null;
                  });
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
    );

    if (result == true) {
      await ref.read(pinStatusProvider.notifier).set(controller.text);
      if (context.mounted) {
        brandToast(context, 'PIN saved.');
      }
      return true;
    }
    return false;
  }
}

/// The user's own row, lifted to the top of Settings where people look for
/// their profile, rather than left buried among the household.
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final self = ref.watch(selfProvider);
    if (self == null) return const SizedBox.shrink();

    final muted = Theme.of(context).colorScheme.outline;
    // Self is seeded unnamed and nothing else in the app asks for a name, so
    // this card is where it gets requested.
    final named = self.name.trim().isNotEmpty;
    final initials = Fmt.initials(self.name);

    return TintCard(
      padding: EdgeInsets.zero,
      child: BrandTile(
        leading: PersonAvatar(
          photoPath: self.photoPath,
          color: Color(self.color),
          size: 52,
          fallback: initials.isEmpty
              ? null
              : Text(
                  initials,
                  style: TextStyle(
                    color: Color(self.color),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
        ),
        title: Text(
          named ? self.name : 'Add your name',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: named ? null : Theme.of(context).colorScheme.primary,
          ),
        ),
        subtitle: Text(
          named ? self.relation : 'So the app knows what to call you',
          style: TextStyle(fontSize: 12, color: muted),
        ),
        trailing: const AppIcon(AppIcons.chevronRight),
        onTap: () => PersonEditor.show(context, ref, person: self),
      ),
    );
  }
}
