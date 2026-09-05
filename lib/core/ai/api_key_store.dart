import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../settings/app_settings.dart';
import 'ai_provider.dart';

final apiKeyStoreProvider = Provider<ApiKeyStore>(
  (ref) => ApiKeyStore(const FlutterSecureStorage()),
);

/// Provider API keys, kept in the platform keychain.
///
/// SharedPreferences is where every other setting lives, but it is a plain
/// file in app-private storage: readable on a rooted device or through a
/// backup. A key that bills the user's account belongs behind the keystore.
class ApiKeyStore {
  ApiKeyStore(this._storage);

  final FlutterSecureStorage _storage;

  static String keyFor(AiProvider p) => 'ai_api_key_${p.name}';

  Future<String?> read(AiProvider p) async {
    try {
      final value = await _storage.read(key: keyFor(p));
      return value == null || value.isEmpty ? null : value;
    } on Exception catch (e) {
      debugPrint('Secure storage read failed: $e');
      return null;
    }
  }

  /// Saves a trimmed key. An empty string removes it, so the settings dialog
  /// can clear a key through the same path it sets one.
  Future<void> write(AiProvider p, String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return delete(p);
    await _storage.write(key: keyFor(p), value: trimmed);
  }

  Future<void> delete(AiProvider p) => _storage.delete(key: keyFor(p));
}

/// Whether a key is saved for the current provider, as something a widget can
/// watch. The value is the key's last four characters, enough for the
/// settings row to say "Key saved •••• ab12" without ever holding the key.
///
/// Reading the keychain is asynchronous and the settings row must rebuild
/// when the key or the provider changes, which is the same reason
/// `pinStatusProvider` exists next to `SecurityService.hasPin`.
final aiKeyStatusProvider = AsyncNotifierProvider<AiKeyStatus, String?>(
  AiKeyStatus.new,
);

class AiKeyStatus extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final provider = ref.watch(settingsProvider.select((s) => s.aiProvider));
    final key = await ref.watch(apiKeyStoreProvider).read(provider);
    return _last4(key);
  }

  Future<void> save(String key) async {
    final provider = ref.read(settingsProvider).aiProvider;
    // Pass through loading first: a replacement key that happens to end in
    // the same four characters would otherwise be an equal state, and the
    // client that watches this would keep the old key.
    state = const AsyncLoading();
    await ref.read(apiKeyStoreProvider).write(provider, key);
    state = AsyncData(_last4(key.trim()));
  }

  Future<void> clear() async {
    final provider = ref.read(settingsProvider).aiProvider;
    await ref.read(apiKeyStoreProvider).delete(provider);
    state = const AsyncData(null);
  }

  static String? _last4(String? key) {
    if (key == null || key.isEmpty) return null;
    return key.length <= 4 ? key : key.substring(key.length - 4);
  }
}
