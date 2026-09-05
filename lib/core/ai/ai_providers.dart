import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../settings/app_settings.dart';
import 'ai_client.dart';
import 'ai_provider.dart';
import 'api_key_store.dart';
import 'clients/anthropic_client.dart';
import 'clients/gemini_client.dart';
import 'clients/openai_compatible_client.dart';

/// One connection pool for the app's only network traffic.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// The client for the configured provider, or null when no key is saved,
/// which is the signal to fall back to the offline parser. Rebuilds when the
/// provider, the model or the key changes.
final aiClientProvider = FutureProvider<AiClient?>((ref) async {
  // Only the two fields the client is built from; a theme or quiet-hours
  // change must not re-read the keychain.
  final (provider, model) = ref.watch(
    settingsProvider.select((s) => (s.aiProvider, s.effectiveAiModel)),
  );
  final last4 = await ref.watch(aiKeyStatusProvider.future);
  if (last4 == null) return null;

  final key = await ref.read(apiKeyStoreProvider).read(provider);
  if (key == null) return null;

  final httpClient = ref.watch(httpClientProvider);
  return switch (provider) {
    AiProvider.anthropic => AnthropicClient(
      apiKey: key,
      model: model,
      httpClient: httpClient,
    ),
    AiProvider.openai => OpenAiCompatibleClient.openAi(
      apiKey: key,
      model: model,
      httpClient: httpClient,
    ),
    AiProvider.gemini => GeminiClient(
      apiKey: key,
      model: model,
      httpClient: httpClient,
    ),
    AiProvider.deepseek => OpenAiCompatibleClient.deepSeek(
      apiKey: key,
      model: model,
      httpClient: httpClient,
    ),
  };
});
