import 'package:flutter/material.dart';

import '../core/constants/modules.dart';
import '../core/storage/local_store.dart';

/// App-wide preferences: theme mode, accent color, which modules are enabled
/// (spec design principle #1 — modular), and whether onboarding is done.
class SettingsController extends ChangeNotifier {
  SettingsController(this._store) {
    _load();
  }

  static const _key = 'settings';
  final LocalStore _store;

  ThemeMode _themeMode = ThemeMode.system;
  Color _accent = const Color(0xFF5B6CFF);
  bool _onboarded = false;
  Set<ModuleId> _enabled = ModuleId.values.toSet();

  ThemeMode get themeMode => _themeMode;
  Color get accent => _accent;
  bool get onboarded => _onboarded;
  Set<ModuleId> get enabled => _enabled;

  bool isEnabled(ModuleId id) => _enabled.contains(id);

  List<ModuleInfo> get enabledModules =>
      kModules.where((m) => _enabled.contains(m.id)).toList();

  void _load() {
    final m = _store.readMap(_key);
    if (m.isEmpty) return;
    _themeMode = ThemeMode.values.byName(m['themeMode'] as String? ?? 'system');
    _accent = Color(m['accent'] as int? ?? 0xFF5B6CFF);
    _onboarded = m['onboarded'] as bool? ?? false;
    final enabledNames = (m['enabled'] as List?)?.cast<String>();
    if (enabledNames != null) {
      _enabled = enabledNames
          .map((n) => ModuleId.values.asNameMap()[n])
          .whereType<ModuleId>()
          .toSet();
    }
  }

  Future<void> _persist() => _store.writeMap(_key, {
        'themeMode': _themeMode.name,
        'accent': _accent.toARGB32(),
        'onboarded': _onboarded,
        'enabled': _enabled.map((e) => e.name).toList(),
      });

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _persist();
    notifyListeners();
  }

  void setAccent(Color color) {
    _accent = color;
    _persist();
    notifyListeners();
  }

  void toggleModule(ModuleId id, bool enabled) {
    _enabled = {..._enabled};
    if (enabled) {
      _enabled.add(id);
    } else {
      _enabled.remove(id);
    }
    _persist();
    notifyListeners();
  }

  void completeOnboarding(Set<ModuleId> modules) {
    _enabled = modules.isEmpty ? ModuleId.values.toSet() : modules;
    _onboarded = true;
    _persist();
    notifyListeners();
  }
}
