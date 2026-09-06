import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/people/avatar_storage.dart';
import 'core/router/app_router.dart';
import 'core/people/people_repository.dart';
import 'core/services/notification_service.dart';
import 'core/services/reminder_sync.dart';
import 'core/services/reminder_target.dart';
import 'core/services/security_service.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_forui_theme.dart';
import 'core/theme/app_icons.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'presentation/notes/repository/note_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Settings are read synchronously all over the app, so load them before the
  // first frame rather than threading an AsyncValue through every screen.
  final prefs = await SharedPreferences.getInstance();
  // Avatars resolve their directory the same way, so the people repository can
  // stay synchronous.
  final avatars = await openAvatarStorage();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        avatarStorageProvider.overrideWithValue(avatars),
      ],
      child: const MySuiteApp(),
    ),
  );
}

class MySuiteApp extends ConsumerStatefulWidget {
  const MySuiteApp({super.key});

  @override
  ConsumerState<MySuiteApp> createState() => _MySuiteAppState();
}

class _MySuiteAppState extends ConsumerState<MySuiteApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startupTasks());
  }

  /// Housekeeping that must not block the first frame.
  Future<void> _startupTasks() async {
    final notifier = ref.read(notificationServiceProvider);
    // A tapped reminder lands on the screen it is about. The handler goes in
    // before init so a tap during startup is not lost.
    notifier.onTap = _openReminder;
    await notifier.init();
    // Notes older than the 30-day trash window are dropped once per launch.
    await ref.read(noteRepositoryProvider).purgeExpiredTrash();
    // Avatar files a half-finished write left behind.
    await ref.read(peopleRepositoryProvider).pruneOrphanedAvatars();
    // Whatever the database says is due gets its notification, so reminders
    // survive rows that arrived without one and schedules that were cleared.
    await ref.read(reminderSyncProvider).syncAll();
    // A tap that cold-started the app is reported here rather than to onTap.
    final launch = await notifier.launchPayload();
    if (launch != null) _openReminder(launch);
  }

  void _openReminder(String payload) {
    final target = ReminderTarget.parse(payload);
    if (target == null) return;
    ref.read(appRouterProvider).push(target.route, extra: target.extra);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'mySuite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(
        palette: settings.palette,
        compact: settings.compactDensity,
        locale: settings.locale,
      ),
      darkTheme: AppTheme.dark(
        palette: settings.palette,
        compact: settings.compactDensity,
        locale: settings.locale,
      ),
      // Material crossfades a theme change on its own; this is only here so
      // the duration can be zeroed for reduce-motion, in step with FTheme.
      themeAnimationDuration: settings.reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 200),
      themeMode: settings.themeMode,
      routerConfig: router,
      locale: Locale(settings.locale),
      supportedLocales: const [Locale('en'), Locale('bn')],
      localizationsDelegates: const [
        // forui ships its own strings and covers both en and bn.
        ...FLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Apply the user's font scale on top of the platform setting.
        final media = MediaQuery.of(context);

        // MaterialApp resolves themeMode itself, but FTheme takes one concrete
        // FThemeData, so the brightness has to be decided here.
        final brightness = switch (settings.themeMode) {
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
          ThemeMode.system => media.platformBrightness,
        };

        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(settings.textScale),
            disableAnimations: settings.reduceMotion,
          ),
          child: FTheme(
            // Both halves of the theme animate a palette change. Reduce motion
            // is a full-screen colour crossfade's most obvious customer, and
            // Flutter's implicit animations do not consult
            // MediaQuery.disableAnimations, so it has to be passed explicitly
            // here and to themeAnimationDuration above.
            motion: FThemeMotion(
              duration: settings.reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
            ),
            data: brandForuiTheme(
              brightness: brightness,
              palette: settings.palette,
              compact: settings.compactDensity,
              locale: settings.locale,
            ),
            // FToaster hosts showFToast; FTooltipGroup coordinates FTooltips so
            // only one is open at a time. Both must sit above every route.
            child: FToaster(
              child: FTooltipGroup(
                child: _LockGate(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Blocks the UI behind biometrics or a PIN when app lock is on, and re-locks
/// after the configured idle period in the background.
class _LockGate extends ConsumerStatefulWidget {
  final Widget child;
  const _LockGate({required this.child});

  @override
  ConsumerState<_LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<_LockGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _prompting = false;
  DateTime? _backgroundedAt;

  // The PIN is entered on the gate itself rather than in a dialog. `_LockGate`
  // is mounted in `MaterialApp.builder`, above the router's Navigator, so
  // `showFDialog` from here throws "Navigator operation requested with a
  // context that does not include a Navigator". `ModuleLockGate` sits inside a
  // route and can still use `promptForPin`; this one cannot.
  final TextEditingController _pin = TextEditingController();
  bool _pinMode = false;
  String? _pinError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  @override
  void dispose() {
    _pin.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settings = ref.read(settingsProvider);
    if (!settings.appLockEnabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundedAt ??= DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed && _backgroundedAt != null) {
      final away = DateTime.now().difference(_backgroundedAt!);
      _backgroundedAt = null;
      if (away.inMinutes >= settings.autoLockMinutes) {
        setState(() {
          _unlocked = false;
          _pinMode = false;
          _pinError = null;
          _pin.clear();
        });
        _evaluate();
      }
    }
  }

  Future<void> _evaluate() async {
    final settings = ref.read(settingsProvider);
    if (!settings.appLockEnabled) {
      if (!_unlocked && mounted) setState(() => _unlocked = true);
      return;
    }
    if (_unlocked || _prompting) return;

    _prompting = true;
    final ok = await ref.read(securityServiceProvider).authenticate();
    _prompting = false;
    if (mounted && ok) setState(() => _unlocked = true);
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(settingsProvider).appLockEnabled && !_unlocked;
    if (!locked) return widget.child;

    return BrandScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppIcon(AppIcons.lock, size: 56),
              const SizedBox(height: 20),
              const Text(
                'mySuite is locked',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Authenticate to continue.',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
              const SizedBox(height: 28),
              if (_pinMode) ..._pinEntry() else ..._authButtons(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _authButtons() => [
    BrandButton(
      label: 'Unlock',
      icon: AppIcons.biometric,
      expand: false,
      onPressed: _evaluate,
    ),
    const SizedBox(height: 8),
    BrandButton(
      label: 'Use PIN instead',
      kind: BrandButtonKind.ghost,
      expand: false,
      onPressed: _startPinEntry,
    ),
  ];

  List<Widget> _pinEntry() => [
    BrandField(
      controller: _pin,
      label: 'PIN',
      error: _pinError,
      autofocus: true,
      obscure: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onSubmit: (_) => _submitPin(),
    ),
    const SizedBox(height: 16),
    BrandButton(label: 'Unlock', expand: false, onPressed: _submitPin),
    const SizedBox(height: 8),
    BrandButton(
      label: 'Use biometrics instead',
      kind: BrandButtonKind.ghost,
      expand: false,
      onPressed: () => setState(() {
        _pinMode = false;
        _pinError = null;
        _pin.clear();
      }),
    ),
  ];

  void _startPinEntry() {
    if (!ref.read(securityServiceProvider).hasPin) {
      brandToast(context, 'No PIN is set on this device.');
      return;
    }
    setState(() => _pinMode = true);
  }

  void _submitPin() {
    if (ref.read(securityServiceProvider).verifyPin(_pin.text)) {
      setState(() => _unlocked = true);
      return;
    }
    setState(() {
      _pinError = 'Incorrect PIN';
      _pin.clear();
    });
  }
}
