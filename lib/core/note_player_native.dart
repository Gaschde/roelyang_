import 'dart:async';

import 'package:flutter_soloud/flutter_soloud.dart';

/// Plays one note at a time per course.
class NotePlayer {
  final _sources = <String, AudioSource>{};
  final _voices = <int, SoundHandle>{};

  Future<void> init(Iterable<String> noteIds) async {
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) await soloud.init();
    for (final id in noteIds) {
      _sources[id] = await soloud.loadAsset('assets/audio/$id.mp3');
    }
  }

  void pluck(int course, String noteId) {
    final source = _sources[noteId];
    if (source == null) return;
    final soloud = SoLoud.instance;
    final previous = _voices[course];
    if (previous != null) unawaited(soloud.stop(previous));
    _voices[course] = soloud.play(source);
  }

  void dispose() {
    final soloud = SoLoud.instance;
    if (soloud.isInitialized) soloud.deinit();
  }
}
