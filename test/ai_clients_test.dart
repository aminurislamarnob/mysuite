import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mysuite/core/ai/ai_client.dart';
import 'package:mysuite/core/ai/ai_command_schema.dart';
import 'package:mysuite/core/ai/ai_provider.dart';
import 'package:mysuite/core/ai/clients/anthropic_client.dart';
import 'package:mysuite/core/ai/clients/gemini_client.dart';
import 'package:mysuite/core/ai/clients/openai_compatible_client.dart';

/// Each client is checked against a recorded request: the URL, the auth
/// header, and the field that asks for schema-bound JSON. Those are the
/// parts a provider rejects silently or with a vague 400 when wrong.
void main() {
  final schema = AiCommandSchema.root;
  http.Request? seen;
  Map<String, Object?> body() =>
      Map<String, Object?>.from(jsonDecode(seen!.body) as Map);

  MockClient respond(int status, Object json) => MockClient((request) async {
    seen = request;
    return http.Response(
      jsonEncode(json),
      status,
      headers: {'content-type': 'application/json'},
    );
  });

  group('AnthropicClient', () {
    test('sends structured output config and reads the text block', () async {
      final client = AnthropicClient(
        apiKey: 'sk-ant-test',
        model: 'claude-opus-5',
        httpClient: respond(200, {
          'model': 'claude-opus-5',
          'stop_reason': 'end_turn',
          'content': [
            {'type': 'thinking', 'thinking': ''},
            {'type': 'text', 'text': '{"actions":[]}'},
          ],
        }),
      );
      final r = await client.complete(system: 's', user: 'u', schema: schema);
      expect(r.text, '{"actions":[]}');
      expect(r.model, 'claude-opus-5');

      expect(seen!.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(seen!.headers['x-api-key'], 'sk-ant-test');
      expect(seen!.headers['anthropic-version'], '2023-06-01');
      final b = body();
      expect(b['system'], 's');
      expect((b['messages'] as List).single, {'role': 'user', 'content': 'u'});
      final output = b['output_config'] as Map;
      expect((output['format'] as Map)['type'], 'json_schema');
      expect((output['format'] as Map)['schema'], isNotNull);
      expect(b.containsKey('tool_choice'), isFalse);
      expect(b.containsKey('tools'), isFalse);
    });

    test('maps refusal, auth, rate limit and transport failures', () async {
      Future<void> expectError(
        MockClient http,
        Matcher matcher, {
        String? message,
      }) async {
        final client = AnthropicClient(
          apiKey: 'k',
          model: 'm',
          httpClient: http,
        );
        await expectLater(
          client.complete(system: 's', user: 'u', schema: schema),
          throwsA(
            message == null
                ? matcher
                : allOf(
                    matcher,
                    predicate<AiException>((e) => e.message == message),
                  ),
          ),
        );
      }

      await expectError(
        respond(200, {'stop_reason': 'refusal', 'content': []}),
        isA<AiRefusalException>(),
      );
      await expectError(
        respond(401, {
          'error': {
            'type': 'authentication_error',
            'message': 'invalid x-api-key',
          },
        }),
        isA<AiAuthException>(),
        message: 'invalid x-api-key',
      );
      await expectError(
        respond(429, {
          'error': {'message': 'rate limited'},
        }),
        isA<AiRateLimitException>(),
      );
      await expectError(
        respond(529, {
          'error': {'message': 'overloaded'},
        }),
        isA<AiNetworkException>(),
      );
      await expectError(
        MockClient((_) async => throw http.ClientException('no route')),
        isA<AiNetworkException>(),
        message: 'no route',
      );
      await expectError(
        respond(200, {'stop_reason': 'max_tokens', 'content': []}),
        isA<AiMalformedException>(),
      );
    });
  });

  group('OpenAiCompatibleClient', () {
    const reply = {
      'model': 'gpt-4.1-mini',
      'choices': [
        {
          'finish_reason': 'stop',
          'message': {'role': 'assistant', 'content': '{"actions":[]}'},
        },
      ],
    };

    test('OpenAI uses strict json_schema and a bearer token', () async {
      final client = OpenAiCompatibleClient.openAi(
        apiKey: 'sk-test',
        model: 'gpt-4.1-mini',
        httpClient: respond(200, reply),
      );
      final r = await client.complete(system: 's', user: 'u', schema: schema);
      expect(r.text, '{"actions":[]}');
      expect(client.provider, AiProvider.openai);

      expect(
        seen!.url.toString(),
        'https://api.openai.com/v1/chat/completions',
      );
      expect(seen!.headers['authorization'], 'Bearer sk-test');
      final format = body()['response_format'] as Map;
      expect(format['type'], 'json_schema');
      expect((format['json_schema'] as Map)['strict'], isTrue);
      expect((format['json_schema'] as Map)['schema'], isNotNull);
      final messages = body()['messages'] as List;
      expect((messages.first as Map)['content'], 's');
    });

    test(
      'DeepSeek uses json_object with the schema in the system prompt',
      () async {
        final client = OpenAiCompatibleClient.deepSeek(
          apiKey: 'sk-ds',
          model: 'deepseek-chat',
          httpClient: respond(200, reply),
        );
        await client.complete(system: 's', user: 'u', schema: schema);
        expect(client.provider, AiProvider.deepseek);
        expect(
          seen!.url.toString(),
          'https://api.deepseek.com/chat/completions',
        );
        expect(body()['response_format'], {'type': 'json_object'});
        final system = ((body()['messages'] as List).first as Map)['content'];
        expect(system, contains('"needs_clarification"'));
      },
    );

    test('a content filter or refusal message is a refusal', () async {
      final filtered = OpenAiCompatibleClient.openAi(
        apiKey: 'k',
        model: 'm',
        httpClient: respond(200, {
          'choices': [
            {
              'finish_reason': 'content_filter',
              'message': {'content': null},
            },
          ],
        }),
      );
      await expectLater(
        filtered.complete(system: 's', user: 'u', schema: schema),
        throwsA(isA<AiRefusalException>()),
      );
      final refused = OpenAiCompatibleClient.openAi(
        apiKey: 'k',
        model: 'm',
        httpClient: respond(200, {
          'choices': [
            {
              'finish_reason': 'stop',
              'message': {'refusal': "I can't help with that."},
            },
          ],
        }),
      );
      await expectLater(
        refused.complete(system: 's', user: 'u', schema: schema),
        throwsA(isA<AiRefusalException>()),
      );
    });
  });

  group('GeminiClient', () {
    const reply = {
      'modelVersion': 'gemini-2.5-flash',
      'candidates': [
        {
          'finishReason': 'STOP',
          'content': {
            'parts': [
              {'text': '{"actions":'},
              {'text': '[]}'},
            ],
          },
        },
      ],
    };

    test('posts to generateContent with responseJsonSchema', () async {
      final client = GeminiClient(
        apiKey: 'AIza',
        model: 'gemini-2.5-flash',
        httpClient: respond(200, reply),
      );
      final r = await client.complete(system: 's', user: 'u', schema: schema);
      expect(r.text, '{"actions":[]}');
      expect(r.model, 'gemini-2.5-flash');

      expect(
        seen!.url.toString(),
        'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-2.5-flash:generateContent',
      );
      expect(seen!.headers['x-goog-api-key'], 'AIza');
      final config = body()['generationConfig'] as Map;
      expect(config['responseMimeType'], 'application/json');
      expect(config['responseJsonSchema'], isNotNull);
      expect(config.containsKey('responseSchema'), isFalse);
      final system = body()['system_instruction'] as Map;
      expect(((system['parts'] as List).first as Map)['text'], 's');
    });

    test('falls back to responseSchema when the field is unknown', () async {
      var calls = 0;
      final client = GeminiClient(
        apiKey: 'k',
        model: 'm',
        httpClient: MockClient((request) async {
          calls++;
          seen = request;
          if (calls == 1) {
            return http.Response(
              jsonEncode({
                'error': {
                  'code': 400,
                  'message': 'Unknown name "responseJsonSchema"',
                  'status': 'INVALID_ARGUMENT',
                },
              }),
              400,
            );
          }
          return http.Response(jsonEncode(reply), 200);
        }),
      );
      await client.complete(system: 's', user: 'u', schema: schema);
      expect(calls, 2);
      final config = body()['generationConfig'] as Map;
      expect(config.containsKey('responseJsonSchema'), isFalse);
      final fallback = config['responseSchema'] as Map;
      expect(fallback.containsKey('additionalProperties'), isFalse);
    });

    test('a safety stop or blocked prompt is a refusal', () async {
      final blocked = GeminiClient(
        apiKey: 'k',
        model: 'm',
        httpClient: respond(200, {
          'promptFeedback': {'blockReason': 'SAFETY'},
          'candidates': [],
        }),
      );
      await expectLater(
        blocked.complete(system: 's', user: 'u', schema: schema),
        throwsA(isA<AiRefusalException>()),
      );
    });
  });
}
