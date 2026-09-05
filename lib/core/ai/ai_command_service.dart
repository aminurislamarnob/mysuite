import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_action.dart';
import 'ai_client.dart';
import 'ai_command_schema.dart';
import 'ai_prompt.dart';
import 'ai_providers.dart';
import 'ai_request_context.dart';
import 'ai_response_parser.dart';
import 'local_command_parser.dart';

final aiCommandServiceProvider = Provider<AiCommandService>(
  (ref) => AiCommandService(ref),
);

/// What one command produced, with the snapshot of names it was parsed
/// against so the executor resolves ids from the same lists the model saw.
typedef AiCommandRun = ({AiCommandResult result, AiRequestContext context});

/// Transcript in, actions out. Picks the configured provider when a key is
/// saved and the offline parser otherwise; either way the result is the same
/// shape, so the screen never knows which one answered beyond the badge.
class AiCommandService {
  AiCommandService(this._ref);

  final Ref _ref;

  Future<AiCommandRun> run(
    String transcript, {
    DateTime? now,
    bool forceOffline = false,
  }) async {
    final context = await buildAiRequestContext(_ref, now: now);
    final client = forceOffline
        ? null
        : await _ref.read(aiClientProvider.future);
    if (client == null) {
      final result = LocalCommandParser.parse(
        transcript,
        context: context,
        now: context.now,
      );
      return (result: result, context: context);
    }

    final raw = await client.complete(
      system: AiPromptBuilder.system(context),
      user: AiPromptBuilder.user(transcript),
      schema: AiCommandSchema.root,
    );
    debugPrint('AI reply from ${client.provider.name}/${raw.model}');
    final result = AiResponseParser.parse(
      raw.text,
      source: RemoteSource(client.provider, raw.model),
      now: context.now,
    );
    return (result: result, context: context);
  }

  /// Whether a request would go to a provider rather than the offline parser.
  Future<bool> get isOnline async =>
      await _ref.read(aiClientProvider.future) != null;

  /// A one-word round trip so the settings screen can prove a key works.
  /// Returns the model name the provider reports.
  Future<String> testConnection() async {
    final client = await _ref.read(aiClientProvider.future);
    if (client == null) {
      throw const AiAuthException('Add an API key first.');
    }
    final raw = await client.complete(
      system:
          'Reply with exactly this JSON and nothing else: '
          '{"actions":[],"reply":"ok","needs_clarification":false}',
      user: 'ping',
      schema: AiCommandSchema.root,
    );
    // Parsing proves the JSON path works end to end, not just the auth.
    AiResponseParser.parse(
      raw.text,
      source: RemoteSource(client.provider, raw.model),
    );
    return raw.model;
  }
}
