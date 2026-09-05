import 'dart:convert';

import 'package:http/http.dart' as http;

import '../ai_client.dart';
import '../ai_provider.dart';

/// OpenAI's chat completions, and DeepSeek, which speaks the same dialect.
///
/// The one difference that matters is JSON: OpenAI validates against a
/// schema in strict mode, DeepSeek only promises "some JSON object", so for
/// DeepSeek the schema rides along in the system message instead.
class OpenAiCompatibleClient implements AiClient {
  OpenAiCompatibleClient({
    required this.provider,
    required this._endpoint,
    required this._apiKey,
    required this.model,
    required this._jsonSchemaMode,
    required http.Client httpClient,
  }) : _http = httpClient;

  factory OpenAiCompatibleClient.openAi({
    required String apiKey,
    required String model,
    required http.Client httpClient,
    Uri? endpoint,
  }) => OpenAiCompatibleClient(
    provider: AiProvider.openai,
    endpoint:
        endpoint ?? Uri.parse('https://api.openai.com/v1/chat/completions'),
    apiKey: apiKey,
    model: model,
    jsonSchemaMode: true,
    httpClient: httpClient,
  );

  factory OpenAiCompatibleClient.deepSeek({
    required String apiKey,
    required String model,
    required http.Client httpClient,
    Uri? endpoint,
  }) => OpenAiCompatibleClient(
    provider: AiProvider.deepseek,
    endpoint:
        endpoint ?? Uri.parse('https://api.deepseek.com/chat/completions'),
    apiKey: apiKey,
    model: model,
    jsonSchemaMode: false,
    httpClient: httpClient,
  );

  @override
  final AiProvider provider;

  @override
  final String model;

  final Uri _endpoint;
  final String _apiKey;
  final bool _jsonSchemaMode;
  final http.Client _http;

  @override
  Future<AiRawResponse> complete({
    required String system,
    required String user,
    required Map<String, Object?> schema,
  }) async {
    final systemText = _jsonSchemaMode
        ? system
        : '$system\n\nRespond only with a JSON object matching this schema:\n'
              '${jsonEncode(schema)}';

    final body = await AiHttp.postJson(
      _http,
      _endpoint,
      headers: {'authorization': 'Bearer $_apiKey'},
      body: {
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemText},
          {'role': 'user', 'content': user},
        ],
        'response_format': _jsonSchemaMode
            ? {
                'type': 'json_schema',
                'json_schema': {
                  'name': 'mysuite_actions',
                  'strict': true,
                  'schema': schema,
                },
              }
            : {'type': 'json_object'},
      },
    );

    final choices = body['choices'];
    final first = choices is List && choices.isNotEmpty ? choices.first : null;
    if (first is! Map) {
      throw AiMalformedException('${provider.label} returned no choices.');
    }
    if (first['finish_reason'] == 'content_filter') {
      throw AiRefusalException('${provider.label} declined to process that.');
    }
    final message = first['message'];
    if (message is Map) {
      final refusal = message['refusal'];
      if (refusal is String && refusal.isNotEmpty) {
        throw AiRefusalException(refusal);
      }
      final content = message['content'];
      if (content is String && content.trim().isNotEmpty) {
        return AiRawResponse(
          text: content,
          model: AiHttp.stringOf(body['model']) ?? model,
        );
      }
    }
    throw AiMalformedException('${provider.label} returned no text.');
  }
}
