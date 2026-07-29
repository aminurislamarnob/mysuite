import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/app_settings.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService(ref.watch(sharedPrefsProvider));
});

/// Whether the app is currently showing its lock screen.
final appLockedProvider = StateProvider<bool>((ref) => false);

/// Biometric and PIN gate for the app and for individual modules.
class SecurityService {
  SecurityService(this._prefs);

  final SharedPreferences _prefs;
  final LocalAuthentication _auth = LocalAuthentication();

  static const _kPinHash = 'pin_hash';
  static const _kPinSalt = 'pin_salt';

  Future<bool> canUseBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on Exception {
      return false;
    }
  }

  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on Exception {
      return const [];
    }
  }

  /// Prompts for biometrics. Falls back to `true` only when no PIN is set and
  /// the device has no biometric hardware, so a user can never lock themselves
  /// out of their own data.
  Future<bool> authenticate({String reason = 'Unlock mySuite'}) async {
    try {
      if (await canUseBiometrics()) {
        return await _auth.authenticate(
          localizedReason: reason,
          biometricOnly: false,
          // Keep the prompt alive if the OS briefly backgrounds the app.
          persistAcrossBackgrounding: true,
        );
      }
    } on Exception catch (e) {
      debugPrint('Biometric auth failed: $e');
    }
    return !hasPin;
  }

  // --- PIN -----------------------------------------------------------------

  bool get hasPin => _prefs.getString(_kPinHash) != null;

  /// Stores a salted SHA-256 digest; the PIN itself is never persisted.
  Future<void> setPin(String pin) async {
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    await _prefs.setString(_kPinSalt, salt);
    await _prefs.setString(_kPinHash, _hash(pin, salt));
  }

  Future<void> clearPin() async {
    await _prefs.remove(_kPinHash);
    await _prefs.remove(_kPinSalt);
  }

  bool verifyPin(String pin) {
    final hash = _prefs.getString(_kPinHash);
    final salt = _prefs.getString(_kPinSalt);
    if (hash == null || salt == null) return true;
    return _hash(pin, salt) == hash;
  }

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();
}
