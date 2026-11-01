import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:roelyang_prototyp/core/pitch_detector.dart';
import 'package:roelyang_prototyp/core/tuning.dart';

Float64List _tone(double hz, {int length = 4096, int sampleRate = 44100}) {
  final samples = Float64List(length);
  for (var i = 0; i < length; i++) {
    final t = i / sampleRate;
    samples[i] =
        0.5 * math.sin(2 * math.pi * hz * t) +
        0.25 * math.sin(2 * math.pi * 2 * hz * t) +
        0.1 * math.sin(2 * math.pi * 3 * hz * t);
  }
  return samples;
}

void main() {
  const detector = PitchDetector();

  for (final note in [so, la, thi, doNote, re, mi, fa]) {
    test('detects ${note.solfege} within 3 cents', () {
      final target = frequencyOf(note.midi, 440);
      final hz = detector.detect(_tone(target));
      expect(hz, isNotNull);
      expect(centsBetween(hz!, target).abs(), lessThan(3));
    });
  }

  test('returns null for silence', () {
    expect(detector.detect(Float64List(4096)), isNull);
  });

  test('returns null when the buffer is too short', () {
    expect(detector.detect(_tone(110, length: 800)), isNull);
  });
}
