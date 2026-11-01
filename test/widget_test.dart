import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roelyang_prototyp/core/tuner_controller.dart';
import 'package:roelyang_prototyp/core/tuning.dart';
import 'package:roelyang_prototyp/main.dart';
import 'package:roelyang_prototyp/ui/info_screens.dart';
import 'package:roelyang_prototyp/ui/theme.dart';
import 'package:roelyang_prototyp/ui/tuner_screen.dart';

void main() {
  void usePhone(WidgetTester tester, Size size) {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  for (final size in const [Size(320, 568), Size(390, 844)]) {
    testWidgets('home fits on a ${size.width}x${size.height} phone', (
      tester,
    ) async {
      usePhone(tester, size);
      await tester.pumpWidget(const RoelyangApp());
      expect(find.text('Roelyang Prototyp'), findsOneWidget);
      expect(find.text('Start tuning'), findsOneWidget);
      expect(find.text('La'), findsOneWidget);
      expect(find.text('Re'), findsOneWidget);
      expect(find.text('So'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tapping a course locks it and tapping again unlocks', (
    tester,
  ) async {
    usePhone(tester, const Size(390, 844));
    await tester.pumpWidget(const RoelyangApp());
    await tester.tap(find.text('Re'));
    await tester.pump();
    expect(find.text('Locked: Re'), findsOneWidget);
    await tester.tap(find.text('Re'));
    await tester.pump();
    expect(find.text('Auto'), findsOneWidget);
  });

  testWidgets('a running tuner shows note, frequency and advice', (
    tester,
  ) async {
    for (final size in const [Size(320, 568), Size(390, 844)]) {
      usePhone(tester, size);
      final tuner = TunerController()
        ..running = true
        ..locked = courses[0]
        ..reading = readingFor(125, a4: 440, locked: courses[0]);
      await tester.pumpWidget(
        MaterialApp(theme: buildTheme(), home: TunerScreen(controller: tuner)),
      );
      expect(find.text('6'), findsOneWidget);
      expect(find.text('B2'), findsOneWidget);
      expect(find.text('125.0 Hz'), findsOneWidget);
      expect(find.text('Loosen a little'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);
      expect(tester.takeException(), isNull);
      tuner.running = false;
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('the top bar does not truncate its labels', (tester) async {
    // The default test font is far wider, so measure with the bundled one.
    await tester.runAsync(
      () => (FontLoader('SpaceGrotesk')
            ..addFont(rootBundle.load('assets/fonts/SpaceGrotesk.ttf')))
          .load(),
    );
    usePhone(tester, const Size(390, 844));
    final tuner = TunerController()
      ..a4 = 441.5
      ..locked = courses[0];
    await tester.pumpWidget(
      MaterialApp(theme: buildTheme(), home: TunerScreen(controller: tuner)),
    );
    for (final label in const ['Locked: La', 'A = 441.5 Hz']) {
      final text = tester.renderObject<RenderParagraph>(find.text(label));
      expect(text.didExceedMaxLines, isFalse, reason: label);
    }
  });

  testWidgets('calibration presets change the concert pitch', (tester) async {
    usePhone(tester, const Size(390, 844));
    await tester.pumpWidget(const RoelyangApp());
    await tester.tap(find.text('A = 440 Hz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('432'));
    await tester.pumpAndSettle();
    expect(find.text('A = 432 Hz'), findsOneWidget);
  });

  testWidgets('learn lists all topics', (tester) async {
    usePhone(tester, const Size(390, 844));
    await tester.pumpWidget(const MaterialApp(home: LearnScreen()));
    for (final title in const [
      'History & origins',
      'The instrument',
      'Notation',
      'Music & genres',
      'Sources',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
  });
}
