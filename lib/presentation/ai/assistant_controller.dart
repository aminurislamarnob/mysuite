import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_action.dart';
import '../../core/ai/ai_client.dart';
import '../../core/ai/ai_command_executor.dart';
import '../../core/ai/ai_command_service.dart';
import '../../core/ai/ai_drafts.dart';
import '../../core/ai/speech_service.dart';
import '../../core/settings/app_settings.dart';

/// The assistant screen's states, in the order a command moves through them.
sealed class AssistantState {
  const AssistantState();
}

class AssistantIdle extends AssistantState {
  const AssistantIdle();
}

class AssistantListening extends AssistantState {
  final String partial;

  const AssistantListening(this.partial);
}

class AssistantTranscript extends AssistantState {
  final String text;

  const AssistantTranscript(this.text);
}

class AssistantThinking extends AssistantState {
  final String transcript;

  const AssistantThinking(this.transcript);
}

class AssistantPreview extends AssistantState {
  final String transcript;
  final AiCommandResult result;
  final List<ActionPreview> previews;

  /// Cards already written, by index, after a tap-to-edit save or a save
  /// that only partly succeeded.
  final Map<int, SavedItem> saved;

  /// Why the last save did not finish: a refused unlock, or the rows that
  /// could not be written. Shown above the cards; the rest can be retried.
  final String? error;

  const AssistantPreview({
    required this.transcript,
    required this.result,
    required this.previews,
    this.saved = const {},
    this.error,
  });

  /// Cards still to be written by "Save all".
  Iterable<int> get pending => [
    for (var i = 0; i < previews.length; i++)
      if (!saved.containsKey(i) && !previews[i].blocked) i,
  ];

  AssistantPreview copyWith({
    List<ActionPreview>? previews,
    Map<int, SavedItem>? saved,
    String? error,
    bool clearError = false,
  }) => AssistantPreview(
    transcript: transcript,
    result: result,
    previews: previews ?? this.previews,
    saved: saved ?? this.saved,
    error: clearError ? null : (error ?? this.error),
  );
}

class AssistantSaving extends AssistantState {
  final String transcript;

  const AssistantSaving(this.transcript);
}

class AssistantSaved extends AssistantState {
  final List<SavedItem> items;
  final String reply;
  final AiSource source;

  const AssistantSaved({
    required this.items,
    this.reply = '',
    required this.source,
  });
}

enum AssistantErrorKind {
  noSpeech,
  noKey,
  auth,
  network,
  rateLimit,
  refused,
  malformed,
  nothingParsed,
  unknown,
}

class AssistantFailure extends AssistantState {
  final AssistantErrorKind kind;
  final String message;
  final String transcript;
  final AiSource? source;

  const AssistantFailure({
    required this.kind,
    required this.message,
    this.transcript = '',
    this.source,
  });
}

final assistantControllerProvider =
    StateNotifierProvider.autoDispose<AssistantController, AssistantState>(
      (ref) => AssistantController(ref),
    );

/// Drives one command from the mic to the rows.
///
/// The screen only renders states and forwards taps; everything that decides
/// what happens next lives here so it can be exercised without widgets.
class AssistantController extends StateNotifier<AssistantState> {
  AssistantController(this._ref)
    : _speech = _ref.read(speechServiceProvider),
      super(const AssistantIdle()) {
    _listening = _speech.listening.listen(_onListening);
  }

  final Ref _ref;

  // Held from construction: dispose runs while the container may already be
  // tearing down, when reading a provider is no longer allowed.
  final SpeechService _speech;
  StreamSubscription<bool>? _listening;
  Timer? _finishTimer;
  String _transcript = '';

  /// Asked before writing into a locked module. Set by the screen, which can
  /// show the biometric prompt; when unset (tests) the write is allowed.
  Future<bool> Function(Set<AppModule> modules)? unlockGate;

  String get transcript => _transcript;

  @override
  void dispose() {
    _finishTimer?.cancel();
    _listening?.cancel();
    if (_speech.isListening) _speech.cancel();
    super.dispose();
  }

  // --- Listening -----------------------------------------------------------

  Future<void> startListening() async {
    _transcript = '';
    state = const AssistantListening('');
    final started = await _speech.listen(
      onResult: (words, isFinal) {
        if (!mounted) return;
        _transcript = words;
        if (isFinal) {
          _finishListening();
        } else {
          state = AssistantListening(words);
        }
      },
    );
    if (!started && mounted) {
      state = const AssistantFailure(
        kind: AssistantErrorKind.noSpeech,
        message: 'Speech recognition is unavailable on this device.',
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// The recogniser went quiet on its own, or after [stopListening].
  ///
  /// Both platforms report "not listening" a moment *before* they deliver
  /// the final result, so finishing here at once would submit the last
  /// partial and then submit again when the final words landed. Give the
  /// final result a short window; if it never comes, go with what we have.
  void _onListening(bool active) {
    if (active || !mounted || state is! AssistantListening) return;
    _finishTimer?.cancel();
    _finishTimer = Timer(const Duration(milliseconds: 600), _finishListening);
  }

  /// Runs once per listening session: the first of the final result and the
  /// grace timer wins, and `submit` leaves the Listening state synchronously
  /// so the other cannot follow.
  void _finishListening() {
    _finishTimer?.cancel();
    _finishTimer = null;
    if (!mounted || state is! AssistantListening) return;
    if (_transcript.trim().isEmpty) {
      state = const AssistantFailure(
        kind: AssistantErrorKind.noSpeech,
        message: 'Nothing was heard. Try again, or type it instead.',
      );
      return;
    }
    // Straight into parsing: the preview is where the user checks the words.
    unawaited(submit());
  }

  // --- Typing --------------------------------------------------------------

  void typeInstead() {
    state = AssistantTranscript(_transcript);
  }

  void editTranscript(String text) {
    _transcript = text;
  }

  // --- Parsing -------------------------------------------------------------

  Future<void> submit({bool forceOffline = false}) async {
    final transcript = _transcript.trim();
    if (transcript.isEmpty) {
      state = AssistantTranscript(_transcript);
      return;
    }
    state = AssistantThinking(transcript);

    AiCommandRun run;
    try {
      run = await _ref
          .read(aiCommandServiceProvider)
          .run(transcript, forceOffline: forceOffline);
    } on AiException catch (e) {
      if (mounted) state = _failure(e, transcript);
      return;
    } on Exception catch (e) {
      debugPrint('Assistant failed: $e');
      if (mounted) {
        state = AssistantFailure(
          kind: AssistantErrorKind.unknown,
          message: 'Something went wrong. Try again.',
          transcript: transcript,
        );
      }
      return;
    }
    if (!mounted) return;

    final result = run.result;
    if (result.actions.isEmpty) {
      state = AssistantFailure(
        kind: AssistantErrorKind.nothingParsed,
        message: result.reply.isNotEmpty
            ? result.reply
            : 'Nothing to add was found in that. Try rephrasing.',
        transcript: transcript,
        source: result.source,
      );
      return;
    }

    final previews = await _ref
        .read(aiCommandExecutorProvider)
        .resolve(result.actions, run.context);
    if (!mounted) return;

    final preview = AssistantPreview(
      transcript: transcript,
      result: result,
      previews: previews,
    );
    state = preview;

    // Auto-save only skips a preview that had nothing to say.
    final settings = _ref.read(settingsProvider);
    if (settings.aiAutoSave &&
        !result.needsClarification &&
        previews.every((p) => p.clean)) {
      await saveAll();
    }
  }

  AssistantFailure _failure(AiException e, String transcript) {
    final kind = switch (e) {
      AiAuthException() => AssistantErrorKind.auth,
      AiRateLimitException() => AssistantErrorKind.rateLimit,
      AiRefusalException() => AssistantErrorKind.refused,
      AiNetworkException() => AssistantErrorKind.network,
      AiMalformedException() => AssistantErrorKind.malformed,
      _ => AssistantErrorKind.unknown,
    };
    return AssistantFailure(
      kind: kind,
      message: e.message,
      transcript: transcript,
    );
  }

  // --- Preview -------------------------------------------------------------

  void removePreview(int index) {
    final s = state;
    if (s is! AssistantPreview) return;
    final previews = List.of(s.previews)..removeAt(index);
    final saved = <int, SavedItem>{
      for (final e in s.saved.entries)
        if (e.key < index)
          e.key: e.value
        else if (e.key > index)
          e.key - 1: e.value,
    };
    if (previews.isEmpty) {
      state = AssistantTranscript(_transcript);
      return;
    }
    state = s.copyWith(previews: previews, saved: saved);
  }

  void markSaved(int index, SavedItem item) {
    final s = state;
    if (s is! AssistantPreview) return;
    state = s.copyWith(saved: {...s.saved, index: item}, clearError: true);
  }

  /// Writes every pending card. Returns false when a lock prompt was refused
  /// or a write failed; the preview stays, with the rows that did get written
  /// marked saved and the reason shown, so a retry only writes the rest.
  Future<bool> saveAll() async {
    final s = state;
    if (s is! AssistantPreview) return false;
    final pending = s.pending.toList();
    if (pending.isEmpty) {
      state = AssistantSaved(
        items: s.saved.values.toList(),
        reply: s.result.reply,
        source: s.result.source,
      );
      return true;
    }

    final locked = _ref.read(settingsProvider).lockedModules;
    final needsUnlock = {
      for (final i in pending)
        if (locked.contains(s.previews[i].draft.module))
          s.previews[i].draft.module,
    };
    if (needsUnlock.isNotEmpty && unlockGate != null) {
      final ok = await unlockGate!(needsUnlock);
      if (!mounted) return false;
      if (!ok) {
        state = s.copyWith(
          error:
              '${needsUnlock.map((m) => m.label).join(', ')} '
              '${needsUnlock.length == 1 ? 'is' : 'are'} locked. '
              'Unlock to save.',
        );
        return false;
      }
    }

    state = AssistantSaving(s.transcript);
    final executor = _ref.read(aiCommandExecutorProvider);
    final outcome = await executor.saveAll([
      for (final i in pending) s.previews[i].draft,
    ]);
    if (!mounted) return false;

    final saved = {...s.saved};
    for (var k = 0; k < pending.length; k++) {
      final item = outcome.results[k];
      if (item != null) saved[pending[k]] = item;
    }

    if (outcome.failures.isEmpty) {
      state = AssistantSaved(
        items: [for (final i in saved.keys.toList()..sort()) saved[i]!],
        reply: s.result.reply,
        source: s.result.source,
      );
      return true;
    }
    state = s.copyWith(saved: saved, error: outcome.failures.join('\n'));
    return false;
  }

  // --- Navigation between states ------------------------------------------

  void discard() {
    _transcript = '';
    state = const AssistantIdle();
  }

  void editAgain() {
    state = AssistantTranscript(_transcript);
  }

  void reset() => discard();
}
