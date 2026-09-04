import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The six toggleable feature modules. Disabling one hides it from the modules
/// grid, the dashboard, and the quick-add sheet.
enum AppModule { notes, medicine, habits, tasks, expenses, focus }

extension AppModuleX on AppModule {
  String get label => switch (this) {
    AppModule.notes => 'Notes',
    AppModule.medicine => 'Medicine',
    AppModule.habits => 'Habits',
    AppModule.tasks => 'Tasks',
    AppModule.expenses => 'Expenses',
    AppModule.focus => 'Focus',
  };

  String get route => switch (this) {
    AppModule.notes => '/notes',
    AppModule.medicine => '/medicine',
    AppModule.habits => '/habits',
    AppModule.tasks => '/tasks',
    AppModule.expenses => '/expenses',
    AppModule.focus => '/focus',
  };

  String get blurb => switch (this) {
    AppModule.notes => 'Rich notes, folders and tags',
    AppModule.medicine => 'Doses, schedules and adherence',
    AppModule.habits => 'Streaks, heatmaps and limits',
    AppModule.tasks => 'Due dates, projects and views',
    AppModule.expenses => 'Budgets, accounts and reports',
    AppModule.focus => 'Pomodoro and focus stats',
  };
}

@immutable
class AppSettings {
  final Set<AppModule> enabledModules;
  final ThemeMode themeMode;
  final bool reduceMotion;
  final bool compactDensity;
  final double textScale;
  final bool appLockEnabled;
  final int autoLockMinutes;
  final Set<AppModule> lockedModules;
  final String currencySymbol;
  final String locale;
  final bool onboardingComplete;
  final bool dndEnabled;
  final int dndStartMinutes;
  final int dndEndMinutes;
  final List<String> dashboardOrder;

  const AppSettings({
    this.enabledModules = const {
      AppModule.notes,
      AppModule.medicine,
      AppModule.habits,
      AppModule.tasks,
      AppModule.expenses,
      AppModule.focus,
    },
    this.themeMode = ThemeMode.system,
    this.reduceMotion = false,
    this.compactDensity = false,
    this.textScale = 1.0,
    this.appLockEnabled = false,
    this.autoLockMinutes = 5,
    this.lockedModules = const {},
    this.currencySymbol = '৳',
    this.locale = 'en',
    this.onboardingComplete = false,
    this.dndEnabled = false,
    this.dndStartMinutes = 22 * 60,
    this.dndEndMinutes = 7 * 60,
    this.dashboardOrder = const [
      'medicine',
      'tasks',
      'habits',
      'expenses',
      'focus',
      'notes',
    ],
  });

  bool isEnabled(AppModule m) => enabledModules.contains(m);

  AppSettings copyWith({
    Set<AppModule>? enabledModules,
    ThemeMode? themeMode,
    bool? reduceMotion,
    bool? compactDensity,
    double? textScale,
    bool? appLockEnabled,
    int? autoLockMinutes,
    Set<AppModule>? lockedModules,
    String? currencySymbol,
    String? locale,
    bool? onboardingComplete,
    bool? dndEnabled,
    int? dndStartMinutes,
    int? dndEndMinutes,
    List<String>? dashboardOrder,
  }) {
    return AppSettings(
      enabledModules: enabledModules ?? this.enabledModules,
      themeMode: themeMode ?? this.themeMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      compactDensity: compactDensity ?? this.compactDensity,
      textScale: textScale ?? this.textScale,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      lockedModules: lockedModules ?? this.lockedModules,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      locale: locale ?? this.locale,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      dndEnabled: dndEnabled ?? this.dndEnabled,
      dndStartMinutes: dndStartMinutes ?? this.dndStartMinutes,
      dndEndMinutes: dndEndMinutes ?? this.dndEndMinutes,
      dashboardOrder: dashboardOrder ?? this.dashboardOrder,
    );
  }
}

/// Set in `main()` before the app boots so settings are readable synchronously.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier(ref.watch(sharedPrefsProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    state = _load();
  }

  static const _kModules = 'enabled_modules';
  static const _kTheme = 'theme_mode';
  static const _kMotion = 'reduce_motion';
  static const _kDensity = 'compact_density';
  static const _kScale = 'text_scale';
  static const _kLock = 'app_lock';
  static const _kAutoLock = 'auto_lock_minutes';
  static const _kLockedModules = 'locked_modules';
  static const _kCurrency = 'currency_symbol';
  static const _kLocale = 'locale';
  static const _kOnboard = 'onboarding_complete';
  static const _kDnd = 'dnd_enabled';
  static const _kDndStart = 'dnd_start';
  static const _kDndEnd = 'dnd_end';
  static const _kDashOrder = 'dashboard_order';

  AppSettings _load() {
    Set<AppModule> parseModules(String key, Set<AppModule> fallback) {
      final raw = _prefs.getStringList(key);
      if (raw == null) return fallback;
      return raw
          .map((n) => AppModule.values.where((m) => m.name == n).firstOrNull)
          .whereType<AppModule>()
          .toSet();
    }

    return AppSettings(
      enabledModules: parseModules(_kModules, AppModule.values.toSet()),
      themeMode:
          ThemeMode.values[(_prefs.getInt(_kTheme) ?? ThemeMode.system.index)
              .clamp(0, ThemeMode.values.length - 1)],
      reduceMotion: _prefs.getBool(_kMotion) ?? false,
      compactDensity: _prefs.getBool(_kDensity) ?? false,
      textScale: _prefs.getDouble(_kScale) ?? 1.0,
      appLockEnabled: _prefs.getBool(_kLock) ?? false,
      autoLockMinutes: _prefs.getInt(_kAutoLock) ?? 5,
      lockedModules: parseModules(_kLockedModules, const {}),
      currencySymbol: _prefs.getString(_kCurrency) ?? '৳',
      locale: _prefs.getString(_kLocale) ?? 'en',
      onboardingComplete: _prefs.getBool(_kOnboard) ?? false,
      dndEnabled: _prefs.getBool(_kDnd) ?? false,
      dndStartMinutes: _prefs.getInt(_kDndStart) ?? 22 * 60,
      dndEndMinutes: _prefs.getInt(_kDndEnd) ?? 7 * 60,
      dashboardOrder:
          _prefs.getStringList(_kDashOrder) ??
          const ['medicine', 'tasks', 'habits', 'expenses', 'focus', 'notes'],
    );
  }

  void toggleModule(AppModule m, bool enabled) {
    final next = {...state.enabledModules};
    enabled ? next.add(m) : next.remove(m);
    _prefs.setStringList(_kModules, next.map((e) => e.name).toList());
    state = state.copyWith(enabledModules: next);
  }

  void setEnabledModules(Set<AppModule> modules) {
    _prefs.setStringList(_kModules, modules.map((e) => e.name).toList());
    state = state.copyWith(enabledModules: modules);
  }

  void toggleModuleLock(AppModule m, bool locked) {
    final next = {...state.lockedModules};
    locked ? next.add(m) : next.remove(m);
    _prefs.setStringList(_kLockedModules, next.map((e) => e.name).toList());
    state = state.copyWith(lockedModules: next);
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setInt(_kTheme, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setReduceMotion(bool v) {
    _prefs.setBool(_kMotion, v);
    state = state.copyWith(reduceMotion: v);
  }

  void setCompactDensity(bool v) {
    _prefs.setBool(_kDensity, v);
    state = state.copyWith(compactDensity: v);
  }

  void setTextScale(double v) {
    _prefs.setDouble(_kScale, v);
    state = state.copyWith(textScale: v);
  }

  void setAppLock(bool v) {
    _prefs.setBool(_kLock, v);
    state = state.copyWith(appLockEnabled: v);
  }

  void setAutoLockMinutes(int v) {
    _prefs.setInt(_kAutoLock, v);
    state = state.copyWith(autoLockMinutes: v);
  }

  void setCurrencySymbol(String v) {
    _prefs.setString(_kCurrency, v);
    state = state.copyWith(currencySymbol: v);
  }

  void setLocale(String v) {
    _prefs.setString(_kLocale, v);
    state = state.copyWith(locale: v);
  }

  void completeOnboarding() {
    _prefs.setBool(_kOnboard, true);
    state = state.copyWith(onboardingComplete: true);
  }

  void setDnd(bool enabled, {int? start, int? end}) {
    _prefs.setBool(_kDnd, enabled);
    if (start != null) _prefs.setInt(_kDndStart, start);
    if (end != null) _prefs.setInt(_kDndEnd, end);
    state = state.copyWith(
      dndEnabled: enabled,
      dndStartMinutes: start,
      dndEndMinutes: end,
    );
  }

  void setDashboardOrder(List<String> order) {
    _prefs.setStringList(_kDashOrder, order);
    state = state.copyWith(dashboardOrder: order);
  }
}
