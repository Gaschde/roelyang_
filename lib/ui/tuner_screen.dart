import 'package:flutter/material.dart';

import '../core/tuner_controller.dart';
import '../core/tuning.dart';
import 'calibration_sheet.dart';
import 'gauge.dart';
import 'info_screens.dart';
import 'play_screen.dart';
import 'theme.dart';

class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key, this.controller});

  /// Stays owned by the caller. Without one the screen creates its own.
  final TunerController? controller;

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  late final TunerController _tuner = widget.controller ?? TunerController();

  @override
  void dispose() {
    if (widget.controller == null) _tuner.dispose();
    super.dispose();
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _openPlay() async {
    await _tuner.stop();
    if (mounted) _open(const PlayScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _tuner,
          builder: (context, _) {
            final width = MediaQuery.sizeOf(context).width - 40;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                children: [
                  _TopBar(
                    tuner: _tuner,
                    onCalibrate: () => showCalibrationSheet(context, _tuner),
                    onLearn: () => _open(const LearnScreen()),
                    onPlay: _openPlay,
                    onAbout: () => _open(const AboutScreen()),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            _tuner.running
                                ? _NoteReadout(_tuner)
                                : const _Header(),
                            const SizedBox(height: 16),
                            TuningGauge(
                              cents: _tuner.reading?.cents,
                              active: _tuner.running,
                            ),
                            const SizedBox(height: 12),
                            StrobeBar(cents: _tuner.reading?.cents),
                            const SizedBox(height: 14),
                            _Status(_tuner),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Tibetan Standard Tuning',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final course in courses)
                        Expanded(
                          child: _CourseCard(
                            course: course,
                            selected: identical(_tuner.locked, course),
                            onTap: () => _tuner.toggleLock(course),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_tuner.running) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _tuner.level,
                        minHeight: 5,
                        color: AppColors.green,
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Mic input',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _StartButton(
                    running: _tuner.running,
                    onPressed: _tuner.running ? _tuner.stop : _tuner.start,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Prototype',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.tuner,
    required this.onCalibrate,
    required this.onLearn,
    required this.onPlay,
    required this.onAbout,
  });

  final TunerController tuner;
  final VoidCallback onCalibrate;
  final VoidCallback onLearn;
  final VoidCallback onPlay;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    final locked = tuner.locked;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: _Pill(
            icon: locked == null ? Icons.mic_none : Icons.lock_outline,
            label: locked == null ? 'Auto' : 'Locked: ${locked.note.solfege}',
            onTap: locked == null ? null : () => tuner.toggleLock(locked),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: _Pill(
            icon: Icons.tune,
            label: 'A = ${formatHz(tuner.a4)} Hz',
            onTap: onCalibrate,
          ),
        ),
        _IconAction(Icons.menu_book_outlined, 'Learn', onLearn),
        _IconAction(Icons.music_note, 'Play', onPlay),
        _IconAction(Icons.info_outline, 'About', onAbout),
      ],
    );
  }
}

String formatHz(double hz) =>
    hz == hz.roundToDouble() ? hz.toStringAsFixed(0) : hz.toStringAsFixed(1);

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction(this.icon, this.tooltip, this.onPressed);

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppColors.muted, size: 22),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 34, height: 44),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const RoelyangMark(),
        const SizedBox(height: 14),
        Text(
          'Roelyang Prototyp',
          textAlign: TextAlign.center,
          style: weighted(
            const TextStyle(fontSize: 30, color: AppColors.text),
            600,
          ),
        ),
      ],
    );
  }
}

class _NoteReadout extends StatelessWidget {
  const _NoteReadout(this.tuner);

  final TunerController tuner;

  @override
  Widget build(BuildContext context) {
    final reading = tuner.reading;
    final color = reading == null
        ? AppColors.muted
        : (reading.isCourse && reading.cents.abs() <= 15
              ? AppColors.greenDeep
              : AppColors.red);
    return Column(
      children: [
        Text(
          reading?.number?.toString() ?? ' ',
          style: const TextStyle(color: AppColors.muted, fontSize: 18),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              reading?.label ?? '–',
              style: weighted(TextStyle(fontSize: 76, color: color, height: 1.05), 600),
            ),
            if (reading != null && reading.letter.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                reading.letter,
                style: const TextStyle(color: AppColors.muted, fontSize: 24),
              ),
            ],
          ],
        ),
        Text(
          reading == null ? 'Listening…' : '${reading.hz.toStringAsFixed(1)} Hz',
          style: const TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }
}

class _Status extends StatelessWidget {
  const _Status(this.tuner);

  final TunerController tuner;

  @override
  Widget build(BuildContext context) {
    if (tuner.permissionDenied) {
      return const Text(
        'Microphone access is off. Allow it in Settings to use the tuner.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.stop, fontSize: 15),
      );
    }
    if (!tuner.running) {
      return const Column(
        children: [
          Text(
            'Tap Start to begin',
            style: TextStyle(color: AppColors.text, fontSize: 18),
          ),
          SizedBox(height: 4),
          Text(
            'Then choose La · Re · So, or just pluck a string',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
        ],
      );
    }
    final reading = tuner.reading;
    if (reading == null) {
      return const Text(
        'Pluck a string',
        style: TextStyle(color: AppColors.muted, fontSize: 18),
      );
    }
    if (!reading.isCourse) {
      return const Text(
        'Not an open course',
        style: TextStyle(color: AppColors.muted, fontSize: 18),
      );
    }
    return Text(
      adviceText(reading.advice),
      style: TextStyle(
        color: reading.cents.abs() <= 15 ? AppColors.green : AppColors.stop,
        fontSize: 18,
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.selected,
    required this.onTap,
  });

  final Course course;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.18)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: selected
              ? const BorderSide(color: AppColors.gold, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Text(
                  course.note.solfege,
                  style: TextStyle(
                    color: selected ? AppColors.gold : AppColors.text,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${course.position} · ${course.note.letter}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.running, required this.onPressed});

  final bool running;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: running ? AppColors.stop : AppColors.gold,
          foregroundColor: running ? Colors.white : const Color(0xFF3A2708),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          running ? 'Stop' : 'Start tuning',
          style: weighted(const TextStyle(fontSize: 20), 600),
        ),
      ),
    );
  }
}
