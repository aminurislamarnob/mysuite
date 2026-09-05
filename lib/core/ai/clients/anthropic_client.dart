import 'package:http/http.dart' as http;

import '../ai_client.dart';
import '../ai_provider.dart';

/// Claude over the Messages API.
///
/// JSON comes back through `output_config.format`, the structured-output
/// path, rather than a forced tool call: the current models reject
/// `tool_choice: any` and assistant prefill, and structured output is the
/// replacement for both. `effort: low` keeps the model's own thinking short
/// for what is a small extraction task.
class AnthropicClient implements AiClient {
  AnthropicClient({
    required this._apiKey,
    required this.model,
    required http.Client httpClient,
    Uri? endpoint,
  }) : _http = httpClient,
       _endpoint =
           endpoint ?? Uri.parse('https://api.anthropic.com/v1/messages');

  static const version = '2023-06-01';

  final String _apiKey;
  final http.Client _http;
  final Uri _endpoint;

  @override
  final String model;

  @override
  AiProvider get provider => AiProvider.anthropic;

  @override
  Future<AiRawResponse> complete({
    required String system,
    required String user,
    required Map<String, Object?> schema,
  }) async {
    final body = await AiHttp.postJson(
      _http,
      _endpoint,
      headers: {'x-api-key': _apiKey, 'anthropic-version': version},
      body: {
        'model': model,
        // Thinking tokens count towards this on models that think by default.
        'max_tokens': 4096,
        'system': system,
        'messages': [
          {'role': 'user', 'content': user},
        ],
        'output_config': {
          'format': {'type': 'json_schema', 'schema': schema},
          'effort': 'low',
        },
      },
    );

    final stop = body['stop_reason'];
    if (stop == 'refusal') {
      throw const AiRefusalException('Claude declined to process that.');
    }
    if (stop == 'max_tokens') {
      throw const AiMalformedException('The reply was cut off.');
    }

    final content = body['content'];
    if (content is List) {
      for (final block in content) {
        if (block is Map && block['type'] == 'text') {
          final text = block['text'];
          if (text is String && text.trim().isNotEmpty) {
            return AiRawResponse(
              text: text,
              model: (body['model'] as String?) ?? model,
            );
          }
        }
      }
    }
    throw const AiMalformedException('Claude returned no text.');
  }
}
