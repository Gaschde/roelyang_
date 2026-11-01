import 'dart:math' as math;
import 'dart:typed_data';

/// YIN fundamental-frequency estimation for the instrument's range.
class PitchDetector {
  const PitchDetector({
    this.sampleRate = 44100,
    this.minHz = 70,
    this.maxHz = 400,
    this.threshold = 0.15,
    this.silenceRms = 0.008,
  });

  final int sampleRate;
  final double minHz;
  final double maxHz;
  final double threshold;
  final double silenceRms;

  static double rms(Float64List samples) {
    if (samples.isEmpty) return 0;
    var sum = 0.0;
    for (final value in samples) {
      sum += value * value;
    }
    return math.sqrt(sum / samples.length);
  }

  /// Returns the frequency in Hz, or null for silence or an unpitched signal.
  double? detect(Float64List samples) {
    final tauMin = (sampleRate / maxHz).floor();
    final tauMax = (sampleRate / minHz).ceil();
    final window = samples.length - tauMax - 1;
    if (window < tauMax || rms(samples) < silenceRms) return null;

    final difference = Float64List(tauMax + 2);
    for (var tau = 1; tau <= tauMax + 1; tau++) {
      var sum = 0.0;
      for (var i = 0; i < window; i++) {
        final delta = samples[i] - samples[i + tau];
        sum += delta * delta;
      }
      difference[tau] = sum;
    }

    final normalized = Float64List(tauMax + 2)..[0] = 1;
    var running = 0.0;
    for (var tau = 1; tau <= tauMax + 1; tau++) {
      running += difference[tau];
      normalized[tau] = running > 0 ? difference[tau] * tau / running : 1;
    }

    for (var tau = math.max(tauMin, 2); tau <= tauMax; tau++) {
      if (normalized[tau] >= threshold) continue;
      while (tau < tauMax && normalized[tau + 1] < normalized[tau]) {
        tau++;
      }
      final before = normalized[tau - 1];
      final at = normalized[tau];
      final after = normalized[tau + 1];
      final curve = before - 2 * at + after;
      final shift = curve.abs() < 1e-12 ? 0.0 : 0.5 * (before - after) / curve;
      return sampleRate / (tau + shift);
    }
    return null;
  }
}
