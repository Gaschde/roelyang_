import 'package:flutter/material.dart';

import '../core/tuner_controller.dart';
import '../core/tuning.dart';
import 'theme.dart';

Future<void> showCalibrationSheet(BuildContext context, TunerController tuner) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _CalibrationSheet(tuner),
  );
}

class _CalibrationSheet extends StatelessWidget {
  const _CalibrationSheet(this.tuner);

  final TunerController tuner;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: ListenableBuilder(
          listenable: tuner,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Calibration', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              const Text(
                'Sets the reference for all three courses.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              const _SectionLabel('CONCERT PITCH'),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Lower',
                    onPressed: () => tuner.setA4(tuner.a4 - 0.5),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          tuner.a4.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 42),
                        ),
                        const Text(
                          'A (Hz)',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    tooltip: 'Raise',
                    onPressed: () => tuner.setA4(tuner.a4 + 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final preset in const [432.0, 440.0, 442.0])
                    Expanded(
                      child: _Preset(
                        value: preset,
                        selected: tuner.a4 == preset,
                        onTap: () => tuner.setA4(preset),
                      ),
                    ),
                ],
              ),
              const Divider(height: 40, color: AppColors.surfaceHigh),
              const _SectionLabel('MATCH YOUR OWN LA'),
              const SizedBox(height: 10),
              const Text(
                'Pluck your La string and capture it. Re and So follow from it.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF3A2708),
                  ),
                  icon: const Icon(Icons.my_location),
                  label: const Text(
                    'Use the La I\'m playing',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: tuner.hearingHz == null
                      ? null
                      : () {
                          if (tuner.captureLa()) {
                            Navigator.of(context).pop();
                          }
                        },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _hearing(tuner),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hearing(TunerController tuner) {
    if (!tuner.running) return 'Start the tuner first.';
    final hz = tuner.hearingHz;
    if (hz == null) return 'Waiting for a note…';
    final a4 = a4ForLa(hz);
    if (a4 < minA4 || a4 > maxA4) {
      return 'Hearing ${hz.toStringAsFixed(1)} Hz, too far from La to capture.';
    }
    return 'Currently hearing ${hz.toStringAsFixed(1)} Hz';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.muted,
      fontSize: 13,
      letterSpacing: 1,
    ),
  );
}

class _Preset extends StatelessWidget {
  const _Preset({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final double value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.18)
            : AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: selected
              ? const BorderSide(color: AppColors.gold, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: selected ? AppColors.gold : AppColors.muted,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
