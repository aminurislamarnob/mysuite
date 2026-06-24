import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin offline-first persistence wrapper over [SharedPreferences].
///
/// Each controller owns a namespaced key and serializes its state to JSON. This
/// keeps the app fully functional with no network (spec design principle #3)
/// while staying simple enough to later swap for SQLite/Drift without touching
/// the controllers' public API.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStore(prefs);
  }

  List<Map<String, dynamic>> readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic> readMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  Future<void> writeMap(String key, Map<String, dynamic> value) {
    return _prefs.setString(key, jsonEncode(value));
  }
}
