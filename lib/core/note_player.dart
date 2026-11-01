// Native builds play through SoLoud. In browsers without cross-origin isolation
// (GitHub Pages, for example) SoLoud mixes on the main thread and tapping lags
// noticeably, so the web build schedules notes with Web Audio directly.
export 'note_player_native.dart'
    if (dart.library.js_interop) 'note_player_web.dart';
