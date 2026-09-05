import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../settings/app_settings.dart';

final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService(ref);
  ref.onDispose(service.dispose);
  return service;
});

/// The one speech recogniser, shared by the assistant and every dictation
/// button.
///
/// Three screens used to each construct their own `SpeechToText` and repeat
/// the same initialise-then-listen dance, and none of them set a locale, so
/// dictation always ran in the device language even with the app in Bangla.
/// Wrapping the plugin once means the locale follows Settings everywhere and
/// the platform quirks (a `false` from initialize, a listen that ends on its
/// own after a pause) are handled in one place.
class SpeechService {
  SpeechService(this._ref);

  final Ref _ref;
  final _stt = stt.SpeechToText();
  final _listening = StreamController<bool>.broadcast();
  bool _ready = false;

  /// True between a successful [listen] and the recogniser going quiet,
  /// whether the user stopped it or it timed out on its own.
  Stream<bool> get listening => _listening.stream;

  bool get isListening => _stt.isListening;

  /// Idempotent. False means no recogniser on this device or permission
  /// denied; the caller decides how to say so.
  Future<bool> initialize() async {
    if (_ready) return true;
    try {
      _ready = await _stt.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _listening.add(false);
          }
        },
        onError: (e) {
          debugPrint('Speech error: ${e.errorMsg}');
          _listening.add(false);
        },
      );
    } on Exception catch (e) {
      debugPrint('Speech init failed: $e');
      _ready = false;
    }
    return _ready;
  }

  /// The recogniser locale that matches the app language, or null for the
  /// device default. Only Bangla is special-cased: it is the one language
  /// the app is localised for that a device is likely not set to.
  Future<String?> preferredLocaleId() async {
    if (_ref.read(settingsProvider).locale != 'bn') return null;
    try {
      final locales = await _stt.locales();
      final bangla = locales.where(
        (l) => l.localeId.toLowerCase().startsWith('bn'),
      );
      if (bangla.isEmpty) return null;
      return bangla
              .where((l) => l.localeId.toLowerCase().contains('bd'))
              .firstOrNull
              ?.localeId ??
          bangla.first.localeId;
    } on Exception catch (e) {
      debugPrint('Could not list speech locales: $e');
      return null;
    }
  }

  /// Starts listening. [onResult] is called with every partial transcript
  /// and once more with `isFinal` true. Returns false when the recogniser is
  /// unavailable.
  Future<bool> listen({
    required void Function(String words, bool isFinal) onResult,
    Duration listenFor = const Duration(seconds: 60),
    Duration pauseFor = const Duration(seconds: 4),
  }) async {
    if (!await initialize()) return false;
    final localeId = await preferredLocaleId();
    try {
      await _stt.listen(
        onResult: (r) {
          onResult(r.recognizedWords, r.finalResult);
          if (r.finalResult) _listening.add(false);
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
          listenFor: listenFor,
          pauseFor: pauseFor,
          localeId: localeId,
        ),
      );
      _listening.add(true);
      return true;
    } on Exception catch (e) {
      debugPrint('Speech listen failed: $e');
      _listening.add(false);
      return false;
    }
  }

  /// Ends the session and lets the recogniser send its final result.
  Future<void> stop() async {
    try {
      await _stt.stop();
    } on Exception catch (e) {
      debugPrint('Speech stop failed: $e');
    }
    _listening.add(false);
  }

  /// Ends the session without a final result.
  Future<void> cancel() async {
    try {
      await _stt.cancel();
    } on Exception catch (e) {
      debugPrint('Speech cancel failed: $e');
    }
    _listening.add(false);
  }

  void dispose() {
    _stt.stop();
    _listening.close();
  }
}
