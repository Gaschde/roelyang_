import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/tuning.dart';
import 'theme.dart';

const double _rangeCents = 50;
const double _amberCents = 15;

/// Semicircular cents gauge with an animated needle.
class TuningGauge extends StatelessWidget {
  const TuningGauge({super.key, required this.cents, required this.active});

  final double? cents;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.75,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: (cents ?? 0).clamp(-_rangeCents, _rangeCents).toDouble()),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        builder: (context, value, _) => CustomPaint(
          painter: _GaugePainter(value, active: active, hasPitch: cents != null),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.cents, {required this.active, required this.hasPitch});

  final double cents;
  final bool active;
  final bool hasPitch;

  double _angle(double value) => -math.pi / 2 + value / _rangeCents * math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width / 2 - 14, size.height - 22);
    final center = Offset(size.width / 2, radius + 14);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final dimmed = active && hasPitch;

    void arc(double from, double to, Color color, StrokeCap cap) {
      canvas.drawArc(
        rect,
        _angle(from),
        _angle(to) - _angle(from),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = cap
          ..color = color,
      );
    }

    // Dim the zones as one layer so their overlapping ends do not show through.
    if (dimmed) {
      canvas.saveLayer(
        null,
        Paint()..color = Colors.white.withValues(alpha: 0.45),
      );
    }
    arc(-_rangeCents, -_amberCents, AppColors.red, StrokeCap.round);
    arc(_amberCents, _rangeCents, AppColors.red, StrokeCap.round);
    arc(-_amberCents, -inTuneCents, AppColors.amber, StrokeCap.butt);
    arc(inTuneCents, _amberCents, AppColors.amber, StrokeCap.butt);
    arc(-inTuneCents, inTuneCents, AppColors.greenDeep, StrokeCap.butt);
    if (dimmed) canvas.restore();

    final tick = Paint()
      ..color = AppColors.muted.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    for (var mark = -40; mark <= 40; mark += 10) {
      final direction = Offset.fromDirection(_angle(mark.toDouble()));
      final length = mark == 0 ? 20.0 : 10.0;
      canvas.drawLine(
        center + direction * (radius - 14),
        center + direction * (radius - 14 - length),
        tick,
      );
    }

    final inTune = hasPitch && cents.abs() <= inTuneCents;
    final needleColor = hasPitch && (inTune || cents.abs() <= _amberCents)
        ? AppColors.green
        : (hasPitch ? AppColors.stop : AppColors.muted);
    final direction = Offset.fromDirection(_angle(cents));
    final side = Offset(-direction.dy, direction.dx) * 3;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + side.dx, center.dy + side.dy)
        ..lineTo(center.dx - side.dx, center.dy - side.dy)
        ..lineTo(
          center.dx + direction.dx * (radius - 8),
          center.dy + direction.dy * (radius - 8),
        )
        ..close(),
      Paint()..color = needleColor,
    );
    canvas.drawCircle(center, 12, Paint()..color = AppColors.surfaceHigh);
    canvas.drawCircle(center, 4, Paint()..color = AppColors.text);

    void flat(String text, Offset at) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, at);
    }

    flat('♭', Offset(center.dx - radius - 14, center.dy - 2));
    flat('♯', Offset(center.dx + radius + 6, center.dy - 2));
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.cents != cents || old.active != active || old.hasPitch != hasPitch;
}

/// Strobe bar: segments drift at a speed proportional to the error.
class StrobeBar extends StatefulWidget {
  const StrobeBar({super.key, required this.cents});

  final double? cents;

  @override
  State<StrobeBar> createState() => _StrobeBarState();
}

class _StrobeBarState extends State<StrobeBar>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _phase = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _syncTicker();
  }

  @override
  void didUpdateWidget(StrobeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  /// Only runs while a pitch is shown, so an idle screen schedules no frames.
  void _syncTicker() {
    final wanted = widget.cents != null;
    if (wanted && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!wanted && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _tick(Duration elapsed) {
    final seconds = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final cents = widget.cents;
    if (cents == null || cents.abs() <= inTuneCents) return;
    setState(() => _phase += cents.clamp(-50.0, 50.0) * seconds * 2);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cents = widget.cents;
    return CustomPaint(
      size: const Size(double.infinity, 18),
      painter: _StrobePainter(
        _phase,
        cents == null
            ? AppColors.surfaceHigh
            : (cents.abs() <= inTuneCents ? AppColors.green : AppColors.greenDeep),
      ),
    );
  }
}

class _StrobePainter extends CustomPainter {
  _StrobePainter(this.phase, this.color);

  final double phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final bar = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(bar, Paint()..color = AppColors.surface);
    canvas.save();
    canvas.clipRRect(bar);
    const period = 32.0;
    final start = phase % period - period;
    for (var x = start; x < size.width; x += period) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, period / 2, size.height),
        Paint()..color = color,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StrobePainter old) =>
      old.phase != phase || old.color != color;
}

/// Prototype mark: a ring with the three courses.
class RoelyangMark extends StatelessWidget {
  const RoelyangMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _MarkPainter());
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.13;
    canvas.drawCircle(center, radius * 0.88, paint);
    final strings = Paint()
      ..color = AppColors.gold
      ..strokeWidth = radius * 0.09
      ..strokeCap = StrokeCap.round;
    for (final x in [-0.32, 0.0, 0.32]) {
      canvas.drawLine(
        center + Offset(x * radius, -radius * 0.45),
        center + Offset(x * radius, radius * 0.45),
        strings,
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => false;
}
