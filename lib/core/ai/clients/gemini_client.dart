import 'package:http/http.dart' as http;

import '../ai_client.dart';
import '../ai_command_schema.dart';
import '../ai_provider.dart';

/// Gemini over the `generateContent` REST endpoint.
///
/// `responseJsonSchema` takes the same JSON Schema every other provider gets.
/// Older API surfaces only know `responseSchema`, an OpenAPI subset without
/// `additionalProperties` or union types, so a 400 that names the newer
/// field is retried once with the converted schema.
class GeminiClient implements AiClient {
  GeminiClient({
    required this._apiKey,
    required this.model,
    required http.Client httpClient,
    Uri? baseUri,
  }) : _http = httpClient,
       _base =
           baseUri ??
           Uri.parse('https://generativelanguage.googleapis.com/v1beta/');

  final String _apiKey;
  final http.Client _http;
  final Uri _base;

  @override
  final String model;

  @override
  AiProvider get provider => AiProvider.gemini;

  Uri get _endpoint => _base.resolve('models/$model:generateContent');

  @override
  Future<AiRawResponse> complete({
    required String system,
    required String user,
    required Map<String, Object?> schema,
  }) async {
    Map<String, Object?> body;
    try {
      body = await _post(system, user, {'responseJsonSchema': schema});
    } on AiException catch (e) {
      final message = e.message.toLowerCase();
      if (e is AiAuthException ||
          e is AiRateLimitException ||
          e is AiNetworkException ||
          !message.contains('json_schema') && !message.contains('jsonschema')) {
        rethrow;
      }
      body = await _post(system, user, {
        'responseSchema': AiCommandSchema.openApiSubset(schema),
      });
    }

    final feedback = body['promptFeedback'];
    if (feedback is Map && feedback['blockReason'] != null) {
      throw const AiRefusalException('Gemini declined to process that.');
    }

    final candidates = body['candidates'];
    final first = candidates is List && candidates.isNotEmpty
        ? candidates.first
        : null;
    if (first is! Map) {
      throw const AiMalformedException('Gemini returned no candidates.');
    }
    final finish = first['finishReason'];
    if (finish == 'SAFETY' || finish == 'PROHIBITED_CONTENT') {
      throw const AiRefusalException('Gemini declined to process that.');
    }
    if (finish == 'MAX_TOKENS') {
      throw const AiMalformedException('The reply was cut off.');
    }

    final content = first['content'];
    final parts = content is Map ? content['parts'] : null;
    if (parts is List) {
      final text = parts
          .whereType<Map>()
          .map((p) => p['text'])
          .whereType<String>()
          .join();
      if (text.trim().isNotEmpty) {
        return AiRawResponse(
          text: text,
          model: (body['modelVersion'] as String?) ?? model,
        );
      }
    }
    throw const AiMalformedException('Gemini returned no text.');
  }

  Future<Map<String, Object?>> _post(
    String system,
    String user,
    Map<String, Object?> schemaField,
  ) {
    return AiHttp.postJson(
      _http,
      _endpoint,
      headers: {'x-goog-api-key': _apiKey},
      body: {
        'system_instruction': {
          'parts': [
            {'text': system},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': user},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          ...schemaField,
        },
      },
    );
  }
}
