import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/services/security_service.dart';
import 'package:mysuite/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a container over an in-memory SharedPreferences, the way `main.dart`
/// overrides the provider at startup.
Future<ProviderContainer> _container([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
}

void main() {
  group('SecurityService PIN storage', () {
    test('the PIN itself is never persisted', () async {
      final container = await _container();
      final security = container.read(securityServiceProvider);

      await security.setPin('1234');

      final prefs = container.read(sharedPrefsProvider);
      for (final key in prefs.getKeys()) {
        expect(prefs.get(key).toString(), isNot(contains('1234')));
      }
    });

    test('the digest is salted, so the same PIN hashes differently', () async {
      final a = await _container();
      final b = await _container();

      await a.read(securityServiceProvider).setPin('1234');
      await b.read(securityServiceProvider).setPin('1234');

      expect(
        a.read(sharedPrefsProvider).getString('pin_hash'),
        isNot(b.read(sharedPrefsProvider).getString('pin_hash')),
      );
    });

    test('verifyPin accepts the stored PIN and rejects others', () async {
      final container = await _container();
      final security = container.read(securityServiceProvider);

      await security.setPin('1234');

      expect(security.verifyPin('1234'), isTrue);
      expect(security.verifyPin('4321'), isFalse);
      expect(security.verifyPin(''), isFalse);
    });

    test('verifyPin fails closed when no PIN is stored', () async {
      // It used to return true here, so any caller that skipped the `hasPin`
      // guard would have unlocked on an empty box.
      final container = await _container();
      final security = container.read(securityServiceProvider);

      expect(security.hasPin, isFalse);
      expect(security.verifyPin(''), isFalse);
      expect(security.verifyPin('1234'), isFalse);
    });

    test('clearPin removes both the digest and the salt', () async {
      final container = await _container();
      final security = container.read(securityServiceProvider);

      await security.setPin('1234');
      await security.clearPin();

      expect(security.hasPin, isFalse);
      expect(container.read(sharedPrefsProvider).getString('pin_salt'), isNull);
    });
  });

  group('pinStatusProvider', () {
    test('reports the stored state on first read', () async {
      final empty = await _container();
      expect(empty.read(pinStatusProvider), isFalse);

      await empty.read(pinStatusProvider.notifier).set('1234');
      final restored = await _container({
        'pin_hash': empty.read(sharedPrefsProvider).getString('pin_hash')!,
        'pin_salt': empty.read(sharedPrefsProvider).getString('pin_salt')!,
      });

      expect(restored.read(pinStatusProvider), isTrue);
    });

    test('notifies listeners when the PIN is set and cleared', () async {
      // The settings row read `SecurityService.hasPin` directly and so kept
      // saying "Set a PIN" after one was saved. This is what makes it rebuild.
      final container = await _container();
      final seen = <bool>[];
      container.listen(pinStatusProvider, (_, next) => seen.add(next));

      await container.read(pinStatusProvider.notifier).set('1234');
      await container.read(pinStatusProvider.notifier).clear();

      expect(seen, [true, false]);
    });
  });
}
