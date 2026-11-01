import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/theme.dart';
import 'ui/tuner_screen.dart';

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
      home: const TunerScreen(),
    );
  }
}
