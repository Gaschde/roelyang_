import 'dart:math' as math;

/// A named note of the D-major scale the instrument uses.
class ScaleNote {
  const ScaleNote(this.id, this.solfege, this.number, this.midi);

  final String id;
  final String solfege;
  final int number;
  final int midi;

  String get letter => noteNameForMidi(midi);
}

const so = ScaleNote('so', 'So', 5, 45); // A2
const la = ScaleNote('la', 'La', 6, 47); // B2
const thi = ScaleNote('thi', 'Thi', 7, 49); // C#3
const doNote = ScaleNote('do', 'Do', 1, 50); // D3
const re = ScaleNote('re', 'Re', 2, 52); // E3
const mi = ScaleNote('mi', 'Mi', 3, 54); // F#3
const fa = ScaleNote('fa', 'Fa', 4, 55); // G3

/// One of the three open double courses.
class Course {
  const Course(this.note, this.position);

  final ScaleNote note;
  final String position;
}

const courses = [Course(la, 'top'), Course(re, 'middle'), Course(so, 'bottom')];

const double defaultA4 = 440;
const double minA4 = 415;
const double maxA4 = 466;
const double inTuneCents = 5;
const double closeCents = 25;

const _letters = ['C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B'];

String noteNameForMidi(int midi) => '${_letters[midi % 12]}${midi ~/ 12 - 1}';

double frequencyOf(int midi, double a4) =>
    a4 * math.pow(2, (midi - 69) / 12).toDouble();

double centsBetween(double hz, double targetHz) =>
    1200 * math.log(hz / targetHz) / math.ln2;

/// The concert pitch that makes [laHz] an exactly in-tune La.
double a4ForLa(double laHz) => laHz / math.pow(2, (la.midi - 69) / 12);

enum Advice { inTune, tightenLittle, tighten, loosenLittle, loosen }

Advice adviceFor(double cents) {
  final size = cents.abs();
  if (size <= inTuneCents) return Advice.inTune;
  if (cents > 0) return size <= closeCents ? Advice.loosenLittle : Advice.loosen;
  return size <= closeCents ? Advice.tightenLittle : Advice.tighten;
}

String adviceText(Advice advice) => switch (advice) {
  Advice.inTune => 'In tune',
  Advice.tightenLittle => 'Tighten a little',
  Advice.tighten => 'Tighten',
  Advice.loosenLittle => 'Loosen a little',
  Advice.loosen => 'Loosen',
};

/// What the tuner shows for one detected frequency.
class TuningReading {
  const TuningReading({
    required this.hz,
    required this.cents,
    required this.label,
    required this.letter,
    required this.number,
    required this.isCourse,
  });

  final double hz;
  final double cents;
  final String label;
  final String letter;
  final int? number;
  final bool isCourse;

  Advice get advice => adviceFor(cents);
}

/// With [locked] set every pitch is measured against that course. Otherwise the
/// nearest chromatic note is used and only open courses get their solfege name.
TuningReading readingFor(double hz, {required double a4, Course? locked}) {
  if (locked != null) {
    final note = locked.note;
    return TuningReading(
      hz: hz,
      cents: centsBetween(hz, frequencyOf(note.midi, a4)),
      label: note.solfege,
      letter: note.letter,
      number: note.number,
      isCourse: true,
    );
  }
  final midi = (69 + centsBetween(hz, a4) / 100).round();
  final cents = centsBetween(hz, frequencyOf(midi, a4));
  for (final course in courses) {
    if (course.note.midi == midi) {
      return TuningReading(
        hz: hz,
        cents: cents,
        label: course.note.solfege,
        letter: course.note.letter,
        number: course.note.number,
        isCourse: true,
      );
    }
  }
  final name = noteNameForMidi(midi);
  return TuningReading(
    hz: hz,
    cents: cents,
    label: name,
    letter: '',
    number: null,
    isCourse: false,
  );
}
