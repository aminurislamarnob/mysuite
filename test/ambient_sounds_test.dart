import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/presentation/focus/providers/focus_provider.dart';

/// The Focus pills used to offer six sounds and ship none of them, so every
/// tap toasted an apology.
///
/// These load through [rootBundle], which is the same path `AssetSource`
/// takes: `AudioCache` asks the bundle for `assets/` plus the track name. A
/// file present on disk but missing from the pubspec would pass a filesystem
/// check and still fail in the app, so the bundle is what gets asked here.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The mono 16-bit samples of a RIFF/WAVE asset, scaled to -1..1.
  Future<({int rate, Float64List samples})> loadWav(String track) async {
    // The prefix `AudioCache` prepends. Keeping it here means a track path
    // that forgets it fails this test rather than the user's tap.
    final bytes = (await rootBundle.load('assets/$track')).buffer.asUint8List();
    final data = ByteData.sublistView(bytes);
    String tag(int at) => String.fromCharCodes(bytes.sublist(at, at + 4));

    expect(tag(0), 'RIFF', reason: '$track is not a RIFF file');
    expect(tag(8), 'WAVE', reason: '$track is not a WAVE file');

    var rate = 0;
    var channels = 0;
    var bits = 0;
    // Walk the chunks rather than assuming `fmt ` then `data` at fixed
    // offsets, which is only true of the simplest writers.
    var at = 12;
    Uint8List? pcm;
    while (at + 8 <= bytes.length) {
      final id = tag(at);
      final size = data.getUint32(at + 4, Endian.little);
      final body = at + 8;
      if (id == 'fmt ') {
        channels = data.getUint16(body + 2, Endian.little);
        rate = data.getUint32(body + 4, Endian.little);
        bits = data.getUint16(body + 14, Endian.little);
      } else if (id == 'data') {
        pcm = bytes.sublist(body, body + size);
      }
      at = body + size + (size.isOdd ? 1 : 0);
    }

    expect(channels, 1, reason: '$track should be mono');
    expect(bits, 16, reason: '$track should be 16-bit PCM');
    expect(pcm, isNotNull, reason: '$track has no data chunk');

    final view = ByteData.sublistView(pcm!);
    final samples = Float64List(pcm.length ~/ 2);
    for (var i = 0; i < samples.length; i++) {
      samples[i] = view.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return (rate: rate, samples: samples);
  }

  test('every offered track is bundled with the app', () async {
    expect(AmbientNotifier.tracks, hasLength(6));
    for (final entry in AmbientNotifier.tracks.entries) {
      await expectLater(
        rootBundle.load('assets/${entry.value}'),
        completion(isA<ByteData>()),
        reason:
            '${entry.key} points at ${entry.value}, which the bundle does '
            'not carry — check the pubspec assets list',
      );
    }
  });

  test('each track is mono 16-bit PCM of a usable length', () async {
    for (final path in AmbientNotifier.tracks.values) {
      final wav = await loadWav(path);
      expect(
        wav.samples.length / wav.rate,
        greaterThanOrEqualTo(3.0),
        reason: '$path is too short to loop without drawing attention',
      );
      expect(
        wav.rate,
        greaterThanOrEqualTo(16000),
        reason: '$path sounds dull',
      );
    }
  });

  test('each track loops without a click', () async {
    for (final path in AmbientNotifier.tracks.values) {
      final samples = (await loadWav(path)).samples;

      // The step from the last sample back to the first is what a listener
      // hears at the seam. Held against a high percentile of the ordinary
      // sample-to-sample steps, it says whether the seam stands out at all.
      final steps = Float64List(samples.length - 1);
      for (var i = 0; i < steps.length; i++) {
        steps[i] = (samples[i + 1] - samples[i]).abs();
      }
      steps.sort();
      final typical = steps[(steps.length * 0.99).floor()];

      expect(
        (samples.first - samples.last).abs(),
        lessThanOrEqualTo(typical),
        reason: '$path jumps at the loop point, which is an audible click',
      );
    }
  });

  test('the tracks sit at one level and none of them clips', () async {
    final levels = <String, double>{};
    for (final entry in AmbientNotifier.tracks.entries) {
      final samples = (await loadWav(entry.value)).samples;
      var sum = 0.0;
      var peak = 0.0;
      for (final s in samples) {
        sum += s * s;
        if (s.abs() > peak) peak = s.abs();
      }
      levels[entry.key] = math.sqrt(sum / samples.length);
      expect(peak, lessThan(0.99), reason: '${entry.key} clips');
    }

    // Switching between them should not be a jump in volume.
    final loudest = levels.values.reduce(math.max);
    final quietest = levels.values.reduce(math.min);
    expect(loudest / quietest, lessThan(1.5));
  });
}
