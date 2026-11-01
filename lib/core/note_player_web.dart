import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

class _Voice {
  _Voice(this.source, this.gain);

  final web.AudioBufferSourceNode source;
  final web.GainNode gain;
}

/// Plays one note at a time per course, using the browser's audio thread.
class NotePlayer {
  static const _unlockEvents = ['pointerdown', 'touchend', 'click', 'keydown'];
  static const _fadeSeconds = 0.008;

  final _buffers = <String, web.AudioBuffer>{};
  final _voices = <int, _Voice>{};
  web.AudioContext? _context;
  late final JSFunction _unlock = (() => _resume()).toJS;

  Future<void> init(Iterable<String> noteIds) async {
    final context = web.AudioContext(
      web.AudioContextOptions(latencyHint: 'interactive'.toJS),
    );
    _context = context;
    // Browsers keep a new context suspended until a user gesture, and Safari
    // only accepts some gestures, so every likely one tries to wake it.
    for (final event in _unlockEvents) {
      web.document.addEventListener(event, _unlock);
    }
    _resume();
    for (final id in noteIds) {
      final data = await rootBundle.load('assets/audio/$id.mp3');
      final bytes = Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      _buffers[id] = await context.decodeAudioData(bytes.buffer.toJS).toDart;
    }
  }

  void pluck(int course, String noteId) {
    final context = _context;
    final buffer = _buffers[noteId];
    if (context == null || buffer == null) return;
    _resume();

    final now = context.currentTime;
    final previous = _voices[course];
    if (previous != null) {
      previous.gain.gain.setTargetAtTime(0, now, _fadeSeconds);
      previous.source.stop(now + _fadeSeconds * 6);
    }

    final gain = context.createGain()..connect(context.destination);
    final source = context.createBufferSource()
      ..buffer = buffer
      ..connect(gain);
    source.start();
    _voices[course] = _Voice(source, gain);
  }

  void dispose() {
    for (final event in _unlockEvents) {
      web.document.removeEventListener(event, _unlock);
    }
    final context = _context;
    _context = null;
    if (context != null) unawaited(context.close().toDart);
  }

  void _resume() {
    final context = _context;
    if (context != null && context.state != 'running') {
      unawaited(context.resume().toDart);
    }
  }
}
