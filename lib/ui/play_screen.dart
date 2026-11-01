import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../core/tuning.dart';

const _courseX = [0.34, 0.63, 0.90];
const _strumLine = 0.53;

/// Stopped notes per course. The third course is a fretless drone.
const _frets = <int, List<ScaleNote>>{
  0: [thi, doNote],
  1: [mi, fa],
};

class _PlayEngine {
  final _sources = <String, AudioSource>{};
  final _voices = <int, SoundHandle>{};

  Future<void> init() async {
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) await soloud.init();
    for (final note in const [so, la, thi, doNote, re, mi, fa]) {
      _sources[note.id] = await soloud.loadAsset('assets/audio/${note.id}.wav');
    }
  }

  void pluck(int course, ScaleNote note) {
    final source = _sources[note.id];
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

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with TickerProviderStateMixin {
  final _engine = _PlayEngine();
  final _heldFret = <int, ScaleNote>{};
  final _pointerX = <int, double>{};
  late final List<AnimationController> _vibration;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _vibration = List.generate(
      courses.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
        value: 1,
      ),
    );
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      await _engine.init();
      if (mounted) setState(() => _ready = true);
    } on Exception catch (error) {
      if (mounted) setState(() => _error = 'Sound could not start: $error');
    }
  }

  @override
  void dispose() {
    for (final controller in _vibration) {
      controller.dispose();
    }
    _engine.dispose();
    super.dispose();
  }

  void _play(int course, ScaleNote note) {
    if (!_ready) return;
    _engine.pluck(course, note);
    _vibration[course].forward(from: 0);
  }

  void _strum(int course) =>
      _play(course, _heldFret[course] ?? courses[course].note);

  void _strumAt(double x, double width) {
    var nearest = 0;
    var distance = double.infinity;
    for (var i = 0; i < _courseX.length; i++) {
      final delta = (_courseX[i] * width - x).abs();
      if (delta < distance) {
        distance = delta;
        nearest = i;
      }
    }
    if (distance <= width * 0.14) _strum(nearest);
  }

  void _strumAcross(double from, double to, double width) {
    for (var i = 0; i < _courseX.length; i++) {
      final x = _courseX[i] * width;
      if ((from < x && to >= x) || (from > x && to <= x)) _strum(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth;
          final height = box.maxHeight;
          final top = MediaQuery.paddingOf(context).top;
          final lineY = height * _strumLine;
          final fretSize = math.min(92.0, width * 0.235);
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7A4A16),
                        Color(0xFFA9742B),
                        Color(0xFF8C5A1E),
                      ],
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: Listenable.merge(_vibration),
                    builder: (context, _) => CustomPaint(
                      painter: _StringsPainter(
                        [for (final c in _vibration) 1 - c.value],
                        lineY,
                      ),
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < courses.length; i++)
                Positioned(
                  left: _courseX[i] * width - 50,
                  width: 100,
                  top: top + 6,
                  child: _CourseLabel(courses[i]),
                ),
              Positioned(
                left: 0,
                right: 0,
                top: lineY,
                bottom: 0,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) {
                    _pointerX[event.pointer] = event.localPosition.dx;
                    _strumAt(event.localPosition.dx, width);
                  },
                  onPointerMove: (event) {
                    final last = _pointerX[event.pointer];
                    if (last != null) {
                      _strumAcross(last, event.localPosition.dx, width);
                    }
                    _pointerX[event.pointer] = event.localPosition.dx;
                  },
                  onPointerUp: (event) => _pointerX.remove(event.pointer),
                  onPointerCancel: (event) => _pointerX.remove(event.pointer),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error ?? 'strum below the line',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              for (final entry in _frets.entries)
                for (var row = 0; row < entry.value.length; row++)
                  Positioned(
                    left: _courseX[entry.key] * width - fretSize / 2,
                    top: top + 80 + row * (lineY - top - 90) / 2,
                    child: _FretButton(
                      size: fretSize,
                      note: entry.value[row],
                      onDown: () {
                        _heldFret[entry.key] = entry.value[row];
                        _play(entry.key, entry.value[row]);
                      },
                      onUp: () {
                        if (identical(_heldFret[entry.key], entry.value[row])) {
                          _heldFret.remove(entry.key);
                        }
                      },
                    ),
                  ),
              Positioned(
                left: _courseX[2] * width - 40,
                width: 80,
                top: top + 110,
                child: Text(
                  'fretless\ndrone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),
              ),
              Positioned(
                left: 6,
                top: top + 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CourseLabel extends StatelessWidget {
  const _CourseLabel(this.course);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          course.note.solfege,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        Text(
          '${course.note.letter} · ${course.position}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FretButton extends StatefulWidget {
  const _FretButton({
    required this.size,
    required this.note,
    required this.onDown,
    required this.onUp,
  });

  final double size;
  final ScaleNote note;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  State<_FretButton> createState() => _FretButtonState();
}

class _FretButtonState extends State<_FretButton> {
  bool _down = false;

  void _release() {
    setState(() => _down = false);
    widget.onUp();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() => _down = true);
        widget.onDown();
      },
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _down ? const Color(0xFFD9BE8F) : const Color(0xFFF1E3CC),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          widget.note.solfege,
          style: const TextStyle(color: Color(0xFF5B3A10), fontSize: 30),
        ),
      ),
    );
  }
}

class _StringsPainter extends CustomPainter {
  _StringsPainter(this.energy, this.lineY);

  final List<double> energy;
  final double lineY;

  @override
  void paint(Canvas canvas, Size size) {
    final string = Paint()
      ..color = const Color(0xFFF7EAD2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < _courseX.length; i++) {
      final x = _courseX[i] * size.width;
      final amplitude = math.pow(energy[i].clamp(0.0, 1.0), 2) * 3.0;
      for (final offset in const [-7.0, 7.0]) {
        canvas.drawPath(
          _wavy(x + offset, size.height, amplitude.toDouble()),
          string,
        );
      }
    }
    final dash = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.5;
    for (var x = 16.0; x < size.width - 16; x += 16) {
      canvas.drawLine(Offset(x, lineY), Offset(x + 9, lineY), dash);
    }
  }

  Path _wavy(double x, double height, double amplitude) {
    final path = Path()..moveTo(x, 0);
    if (amplitude < 0.05) return path..lineTo(x, height);
    for (var y = 0.0; y <= height; y += 12) {
      final shape = math.sin(math.pi * y / height);
      path.lineTo(x + amplitude * shape * math.sin(y / 5), y);
    }
    return path;
  }

  @override
  bool shouldRepaint(_StringsPainter old) => true;
}
