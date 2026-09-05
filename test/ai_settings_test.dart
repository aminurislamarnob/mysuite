import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/ai/ai_provider.dart';
import 'package:mysuite/core/ai/api_key_store.dart';
import 'package:mysuite/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The AI settings follow the rest of the notifier: written to prefs first,
/// then rebuilt into state, and enums travel by name so a reordered enum
/// cannot reassign a saved choice.
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AI settings', () {
    test('defaults: Claude, provider default model, no auto-save', () async {
      final container = await _container();
      final s = container.read(settingsProvider);
      expect(s.aiProvider, AiProvider.anthropic);
      expect(s.aiModel, '');
      expect(s.effectiveAiModel, AiProvider.anthropic.defaultModel);
      expect(s.aiAutoSave, isFalse);
    });

    test('provider round-trips by name', () async {
      final a = await _container();
      a.read(settingsProvider.notifier).setAiProvider(AiProvider.gemini);
      expect(a.read(sharedPrefsProvider).getString('ai_provider'), 'gemini');

      final b = await _container({'ai_provider': 'gemini'});
      expect(b.read(settingsProvider).aiProvider, AiProvider.gemini);
    });

    test('an unknown stored provider name falls back to Claude', () async {
      final container = await _container({'ai_provider': 'mistral'});
      expect(container.read(settingsProvider).aiProvider, AiProvider.anthropic);
    });

    test('changing provider clears the model override', () async {
      final container = await _container();
      final notifier = container.read(settingsProvider.notifier);
      notifier.setAiModel('gpt-4.1');
      expect(container.read(settingsProvider).effectiveAiModel, 'gpt-4.1');

      notifier.setAiProvider(AiProvider.openai);
      final s = container.read(settingsProvider);
      expect(s.aiModel, '');
      expect(s.effectiveAiModel, AiProvider.openai.defaultModel);
      expect(container.read(sharedPrefsProvider).getString('ai_model'), isNull);
    });

    test('a blank model resets to the default', () async {
      final container = await _container();
      final notifier = container.read(settingsProvider.notifier);
      notifier.setAiModel('  custom-model ');
      expect(container.read(settingsProvider).aiModel, 'custom-model');
      notifier.setAiModel('   ');
      expect(container.read(settingsProvider).aiModel, '');
    });
  });

  group('ApiKeyStore', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('round-trips a key per provider', () async {
      final store = ApiKeyStore(const FlutterSecureStorage());
      await store.write(AiProvider.openai, ' sk-test-1234 ');
      expect(await store.read(AiProvider.openai), 'sk-test-1234');
      expect(await store.read(AiProvider.anthropic), isNull);
    });

    test('writing an empty key removes it', () async {
      final store = ApiKeyStore(const FlutterSecureStorage());
      await store.write(AiProvider.deepseek, 'sk-abc');
      await store.write(AiProvider.deepseek, '');
      expect(await store.read(AiProvider.deepseek), isNull);
    });

    test('key status exposes only the last four characters', () async {
      final container = await _container();
      final status = container.read(aiKeyStatusProvider.notifier);
      expect(await container.read(aiKeyStatusProvider.future), isNull);

      await status.save('sk-ant-secret-ab12');
      expect(container.read(aiKeyStatusProvider).value, 'ab12');
      expect(
        await container.read(apiKeyStoreProvider).read(AiProvider.anthropic),
        'sk-ant-secret-ab12',
      );

      await status.clear();
      expect(container.read(aiKeyStatusProvider).value, isNull);
    });
  });
}
