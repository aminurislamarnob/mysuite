import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/people/people_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/security_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../habits/repository/habit_repository.dart';
import '../modules/modules_screen.dart';
import '../../core/widgets/palette_picker.dart';
import '../../core/theme/app_palette.dart';

/// First-run flow: name, language, theme, modules, starter habits, then app
/// lock.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  final Set<AppModule> _modules = AppModule.values.toSet();
  final Set<String> _habits = {};
  final _name = TextEditingController();

  static const _lastPage = 5;

  void _next() {
    if (_index < _lastPage) {
      _pages.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final notifier = ref.read(settingsProvider.notifier);
    notifier.setEnabledModules(_modules);

    // Left blank when skipped, which is what the settings profile card watches
    // for, so skipping here costs nothing but a later prompt.
    final name = _name.text.trim();
    if (name.isNotEmpty) {
      final people = ref.read(peopleRepositoryProvider);
      await people.updatePerson(await people.selfId(), name: name);
    }

    // Seed whichever starter habits were picked.
    if (_modules.contains(AppModule.habits) && _habits.isNotEmpty) {
      final repo = ref.read(habitRepositoryProvider);
      for (final preset in HabitRepository.presets.where(
        (p) => _habits.contains(p.name),
      )) {
        await repo.createHabit(
          HabitsCompanion(
            name: drift.Value(preset.name),
            icon: drift.Value(preset.icon),
            color: drift.Value(preset.color),
            unit: drift.Value(preset.unit),
            goalType: drift.Value(preset.goalType),
            targetAmount: drift.Value(preset.target),
            caffeineMgPerUnit: drift.Value(preset.caffeine),
          ),
        );
      }
    }

    notifier.completeOnboarding();
    if (mounted) context.go('/dashboard');
  }

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: BrandProgressBar(
                      value: (_index + 1) / (_lastPage + 1),
                      semanticsLabel: 'Step ${_index + 1} of ${_lastPage + 1}',
                      color: Theme.of(context).colorScheme.primary,
                      height: 4,
                    ),
                  ),
                  if (_index < _lastPage)
                    BrandButton(
                      label: 'Skip',
                      kind: BrandButtonKind.ghost,
                      expand: false,
                      small: true,
                      onPressed: _finish,
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _welcomePage(),
                  _namePage(),
                  _languagePage(),
                  _themePage(),
                  _modulesPage(),
                  _finishPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: BrandButton(
                label: _index == _lastPage ? 'Get started' : 'Continue',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shell({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(color: context.muted, fontSize: 15, height: 1.45),
          ),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }

  Widget _welcomePage() {
    return _shell(
      title: 'Your day, in one place.',
      subtitle:
          'Notes, medicine, habits, tasks, expenses and focus — one app instead '
          'of six. Everything works offline.',
      child: Column(
        children: [
          for (var i = 0; i < AppModule.values.length; i++)
            Builder(
              builder: (context) {
                final m = AppModule.values[i];
                final (icon, color) = ModulesScreen.metaFor(context, m);
                return Padding(
                  // Wider than a list row's gutter: these are tall feature
                  // cards, and 10 reads cramped under that much weight.
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TintCard(
                    tintIndex: i,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: AppIcon(icon, color: Colors.white, size: 21),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                m.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                m.blurb,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: context.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Asked once, here, because nothing else in the app ever prompts for it —
  /// Self is seeded unnamed, and a user who skips this is nudged from the
  /// settings profile card instead.
  Widget _namePage() {
    return _shell(
      title: 'What should we call you?',
      subtitle:
          'Used for your profile and to tell your records apart from anyone '
          'else in the household. You can change it later, or skip it.',
      child: BrandField(
        controller: _name,
        label: 'Your name',
        hint: 'Aminur',
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        onSubmit: (_) => _next(),
      ),
    );
  }

  Widget _languagePage() {
    final settings = ref.watch(settingsProvider);
    return _shell(
      title: 'Pick your language',
      subtitle: 'You can change this any time in Settings.',
      child: Column(
        children: [
          _choice(
            label: 'English',
            selected: settings.locale == 'en',
            onTap: () => ref.read(settingsProvider.notifier).setLocale('en'),
          ),
          _choice(
            label: 'বাংলা',
            sublabel: 'Bangla',
            selected: settings.locale == 'bn',
            onTap: () => ref.read(settingsProvider.notifier).setLocale('bn'),
          ),
        ],
      ),
    );
  }

  Widget _themePage() {
    final settings = ref.watch(settingsProvider);
    return _shell(
      title: 'Light or dark?',
      subtitle: 'Following your system is usually the easiest.',
      child: Column(
        children: [
          _choice(
            label: 'Follow system',
            selected: settings.themeMode == ThemeMode.system,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ThemeMode.system),
          ),
          _choice(
            label: 'Light',
            selected: settings.themeMode == ThemeMode.light,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ThemeMode.light),
          ),
          _choice(
            label: 'Dark',
            selected: settings.themeMode == ThemeMode.dark,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(height: 24),
          Text('Colour', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            settings.palette.blurb,
            style: TextStyle(color: context.muted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          const PalettePicker(),
        ],
      ),
    );
  }

  Widget _modulesPage() {
    return _shell(
      title: 'Which tools do you want?',
      subtitle:
          'Turn off anything you will not use — you can add it back later.',
      child: Column(
        children: [
          ...AppModule.values.map((m) {
            final (icon, color) = ModulesScreen.metaFor(context, m);
            final on = _modules.contains(m);
            return Padding(
              padding: const EdgeInsets.only(bottom: cardGap),
              child: BrandTile(
                leading: AppIcon(icon, color: color),
                title: Text(
                  m.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(m.blurb, style: const TextStyle(fontSize: 12)),
                trailing: BrandCheckbox(
                  value: on,
                  semanticsLabel: m.label,
                  onChanged: (v) => setState(() {
                    v ? _modules.add(m) : _modules.remove(m);
                  }),
                ),
                onTap: () => setState(() {
                  on ? _modules.remove(m) : _modules.add(m);
                }),
              ),
            );
          }),
          if (_modules.contains(AppModule.habits)) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: BrandDivider(),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Start tracking a few habits?',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HabitRepository.presets
                  .map(
                    (p) => Pill(
                      icon: AppIcons.habit(p.icon),
                      label: p.name,
                      color: Color(p.color),
                      selected: _habits.contains(p.name),
                      onTap: () => setState(() {
                        _habits.contains(p.name)
                            ? _habits.remove(p.name)
                            : _habits.add(p.name);
                      }),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _finishPage() {
    final settings = ref.watch(settingsProvider);
    return _shell(
      title: 'Almost there',
      subtitle: 'Two optional extras, then you are set.',
      child: Column(
        children: [
          BrandSwitchTile(
            leading: const AppIcon(AppIcons.lock),
            title: 'Lock the app',
            subtitle: 'Use biometrics or a PIN on launch',
            value: settings.appLockEnabled,
            onChanged: (v) async {
              final security = ref.read(securityServiceProvider);
              if (v && !await security.canUseBiometrics()) {
                if (!mounted) return;
                brandToast(
                  context,
                  'No biometrics found — set a PIN in Settings.',
                );
              }
              ref.read(settingsProvider.notifier).setAppLock(v);
            },
          ),
          const SizedBox(height: cardGap),
          BrandTile(
            leading: const AppIcon(AppIcons.notificationsActive),
            title: const Text('Allow reminders'),
            subtitle: const Text(
              'Dose times, tasks and bills',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const AppIcon(AppIcons.chevronRight),
            onTap: () async {
              final granted = await ref
                  .read(notificationServiceProvider)
                  .requestPermissions();
              if (mounted) {
                brandToast(
                  context,
                  granted
                      ? 'Reminders enabled.'
                      : 'You can enable these later in Settings.',
                );
              }
            },
          ),
          const SizedBox(height: 24),
          TintCard(
            accent: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AppIcon(
                  AppIcons.privacy,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Everything stays on this device. Nothing is uploaded.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _choice({
    required String label,
    String? sublabel,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final primary = Theme.of(context).colorScheme.primary;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TintCard(
            // The chosen option fills with the brand wash so the selection reads
            // from across the room; the rest stay on the neutral pastel.
            accent: selected ? primary : null,
            onTap: onTap,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: BrandTile(
              title: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: sublabel == null ? null : Text(sublabel),
              trailing: AppIcon(
                selected ? AppIcons.checkCircle : AppIcons.circle,
                color: selected ? primary : context.muted,
              ),
            ),
          ),
        );
      },
    );
  }
}
