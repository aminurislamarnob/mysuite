import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../settings/app_settings.dart';
import 'ai_client.dart';
import 'ai_provider.dart';
import 'ai_request_context.dart';
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

/// A fresh snapshot of the user's names for one command. Auto-disposed so
/// the lists are re-read for every request rather than cached across edits.
final aiRequestContextProvider = FutureProvider.autoDispose<AiRequestContext>(
  (ref) => buildAiRequestContext(ref),
);

/// The client for the configured provider, or null when no key is saved,
/// which is the signal to fall back to the offline parser. Rebuilds when the
/// provider, the model or the key changes.
final aiClientProvider = FutureProvider<AiClient?>((ref) async {
  final settings = ref.watch(settingsProvider);
  final last4 = await ref.watch(aiKeyStatusProvider.future);
  if (last4 == null) return null;

  final key = await ref.read(apiKeyStoreProvider).read(settings.aiProvider);
  if (key == null) return null;

  final httpClient = ref.watch(httpClientProvider);
  final model = settings.effectiveAiModel;
  return switch (settings.aiProvider) {
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
