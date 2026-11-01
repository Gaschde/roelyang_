import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/theme.dart';
import 'ui/tuner_screen.dart';

const _maxWidth = 480.0;
const _minHeight = 568.0;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const RoelyangApp());
}

class RoelyangApp extends StatelessWidget {
  const RoelyangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roelyang Prototyp',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      builder: _phoneFrame,
      home: const TunerScreen(),
    );
  }
}

/// Browsers can be any shape, while the screens are laid out for a phone in
/// portrait. Wide windows get a centred column, short ones are scaled to fit.
Widget _phoneFrame(BuildContext context, Widget? child) {
  final media = MediaQuery.of(context);
  final size = Size(
    math.min(media.size.width, _maxWidth),
    math.max(media.size.height, _minHeight),
  );
  final framed = SizedBox.fromSize(
    size: size,
    child: MediaQuery(
      data: media.copyWith(size: size),
      child: child ?? const SizedBox.shrink(),
    ),
  );
  return ColoredBox(
    color: AppColors.background,
    child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: framed)),
  );
}
