import 'package:flutter_test/flutter_test.dart';
import 'package:roelyang_prototyp/core/tuning.dart';

void main() {
  test('open courses have the expected names and frequencies', () {
    expect(la.letter, 'B2');
    expect(re.letter, 'E3');
    expect(so.letter, 'A2');
    expect(frequencyOf(so.midi, 440), closeTo(110.0, 0.001));
    expect(frequencyOf(la.midi, 440), closeTo(123.47, 0.01));
    expect(frequencyOf(re.midi, 440), closeTo(164.81, 0.01));
  });

  test('fretted notes follow D major numbering', () {
    expect(thi.letter, 'C♯3');
    expect(doNote.letter, 'D3');
    expect(mi.letter, 'F♯3');
    expect(fa.letter, 'G3');
    expect([doNote, re, mi, fa, so, la, thi].map((n) => n.number), [
      1, 2, 3, 4, 5, 6, 7,
    ]);
  });

  test('advice follows the sign and size of the error', () {
    expect(adviceFor(0), Advice.inTune);
    expect(adviceFor(5), Advice.inTune);
    expect(adviceFor(-5), Advice.inTune);
    expect(adviceFor(10), Advice.loosenLittle);
    expect(adviceFor(40), Advice.loosen);
    expect(adviceFor(-10), Advice.tightenLittle);
    expect(adviceFor(-40), Advice.tighten);
  });

  test('auto mode names open courses and letters other notes', () {
    final open = readingFor(123.47, a4: 440);
    expect(open.label, 'La');
    expect(open.isCourse, isTrue);
    expect(open.cents.abs(), lessThan(1));

    final other = readingFor(138.59, a4: 440);
    expect(other.label, 'C♯3');
    expect(other.isCourse, isFalse);
  });

  test('a locked course measures against that course', () {
    final reading = readingFor(165, a4: 440, locked: courses[0]);
    expect(reading.label, 'La');
    expect(reading.cents, greaterThan(400));
  });

  test('capturing La yields a concert pitch where that La is in tune', () {
    expect(a4ForLa(frequencyOf(la.midi, 440)), closeTo(440, 0.001));
    final a4 = a4ForLa(125);
    expect(centsBetween(125, frequencyOf(la.midi, a4)).abs(), lessThan(0.001));
  });
}
