import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'pitch_detector.dart';
import 'tuning.dart';

/// Owns the microphone stream and the tuner state. Audio is analysed live and
/// discarded; nothing is written to disk or sent anywhere.
class TunerController extends ChangeNotifier {
  static const _sampleRate = 44100;
  static const _bufferSize = 4096;
  static const _hopSize = 2048;
  static const _holdFrames = 15;
  static const _inTuneFramesForHaptic = 3;

  final _detector = const PitchDetector(sampleRate: _sampleRate);
  final _ring = Float64List(_bufferSize);
  final _frame = Float64List(_bufferSize);
  final _recent = <double>[];

  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _subscription;
  int? _leftoverByte;
  int _writeIndex = 0;
  int _filled = 0;
  int _sinceAnalysis = 0;
  int _framesWithoutPitch = 0;
  int _inTuneFrames = 0;
  bool _confirmed = false;
  bool _starting = false;

  bool running = false;
  bool permissionDenied = false;
  double a4 = defaultA4;
  double level = 0;
  Course? locked;
  TuningReading? reading;

  double? get hearingHz => reading?.hz;

  void toggleLock(Course course) {
    locked = identical(locked, course) ? null : course;
    _resetDetection();
    notifyListeners();
  }

  void setA4(double value) {
    a4 = value.clamp(minA4, maxA4).toDouble();
    _recompute();
    notifyListeners();
  }

  /// Treats the current pitch as La. Returns false when none is heard or the
  /// result would fall outside the supported concert-pitch range.
  bool captureLa() {
    final hz = hearingHz;
    if (hz == null) return false;
    final candidate = a4ForLa(hz);
    if (candidate < minA4 || candidate > maxA4) return false;
    setA4(candidate);
    return true;
  }

  Future<void> start() async {
    if (running || _starting) return;
    _starting = true;
    try {
      final recorder = AudioRecorder();
      if (!await recorder.hasPermission()) {
        await recorder.dispose();
        permissionDenied = true;
        notifyListeners();
        return;
      }
      final stream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );
      _recorder = recorder;
      _subscription = stream.listen(_onBytes);
      permissionDenied = false;
      running = true;
      _resetDetection();
      await WakelockPlus.enable();
      notifyListeners();
    } finally {
      _starting = false;
    }
  }

  Future<void> stop() async {
    if (!running) return;
    running = false;
    level = 0;
    reading = null;
    notifyListeners();
    await _subscription?.cancel();
    _subscription = null;
    final recorder = _recorder;
    _recorder = null;
    if (recorder != null) {
      await recorder.stop();
      await recorder.dispose();
    }
    await WakelockPlus.disable();
  }

  @override
  void dispose() {
    unawaited(stop());
    super.dispose();
  }

  void _onBytes(Uint8List bytes) {
    var index = 0;
    final pending = _leftoverByte;
    if (pending != null && bytes.isNotEmpty) {
      _addSample(pending | (bytes[0] << 8));
      _leftoverByte = null;
      index = 1;
    }
    for (; index + 1 < bytes.length; index += 2) {
      _addSample(bytes[index] | (bytes[index + 1] << 8));
    }
    if (index < bytes.length) _leftoverByte = bytes[index];
  }

  void _addSample(int unsigned) {
    final signed = unsigned >= 0x8000 ? unsigned - 0x10000 : unsigned;
    _ring[_writeIndex] = signed / 32768;
    _writeIndex = (_writeIndex + 1) % _bufferSize;
    if (_filled < _bufferSize) _filled++;
    if (++_sinceAnalysis >= _hopSize && _filled == _bufferSize) {
      _sinceAnalysis = 0;
      _analyse();
    }
  }

  void _analyse() {
    final oldest = _bufferSize - _writeIndex;
    _frame.setRange(0, oldest, _ring, _writeIndex);
    _frame.setRange(oldest, _bufferSize, _ring);
    level = (PitchDetector.rms(_frame) * 5).clamp(0.0, 1.0).toDouble();
    final hz = _detector.detect(_frame);
    if (hz == null) {
      _framesWithoutPitch++;
      _inTuneFrames = 0;
      if (_framesWithoutPitch > _holdFrames) {
        reading = null;
        _recent.clear();
        _confirmed = false;
      }
    } else {
      _framesWithoutPitch = 0;
      _recent.add(hz);
      if (_recent.length > 5) _recent.removeAt(0);
      _recompute();
      _confirmInTune();
    }
    notifyListeners();
  }

  void _recompute() {
    if (_recent.isEmpty) return;
    final sorted = [..._recent]..sort();
    reading = readingFor(sorted[sorted.length ~/ 2], a4: a4, locked: locked);
  }

  void _confirmInTune() {
    final current = reading;
    if (current == null || !current.isCourse || current.advice != Advice.inTune) {
      _inTuneFrames = 0;
      _confirmed = false;
      return;
    }
    _inTuneFrames++;
    if (_inTuneFrames >= _inTuneFramesForHaptic && !_confirmed) {
      _confirmed = true;
      unawaited(HapticFeedback.mediumImpact());
    }
  }

  void _resetDetection() {
    _recent.clear();
    reading = null;
    _leftoverByte = null;
    _writeIndex = 0;
    _filled = 0;
    _sinceAnalysis = 0;
    _framesWithoutPitch = 0;
    _inTuneFrames = 0;
    _confirmed = false;
  }
}
