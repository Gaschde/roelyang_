# Analyse von Dranyen.ipa

Stand: 2026-11-01. Datei: `Dranyen.ipa`, 19 817 915 Bytes, SHA-256
`1787E4231CCDAB5EE33AB1018ADD6D7A348150A1DCC1754AD3B2A9E85DB64114`.

## Abdeckung

Die IPA konnte **nicht komplett gelesen** werden. Alle sechs Mach-O-Binaries sind
FairPlay-verschlüsselt. Geprüft wurde `cryptid=1` direkt bei `Runner`, `App`, `Flutter`
und `flutter-soloud`. `objective_c` und `FlutterFramework_…` tragen dieselben
`SC_Info`-Dateien. `App.framework/App` enthält den Dart-Code, also die eigentliche
App-Logik und vermutlich die Lern-Texte. Die Verschlüsselung wurde nicht umgangen.

| Quelle | Status |
| --- | --- |
| Info.plist, iTunesMetadata, Privacy-Manifeste | gelesen |
| Asset-Manifest, NOTICES-Paketliste, Mach-O-Ladebefehle | gelesen |
| 7 MP3-Dateien | Tonhöhe gemessen |
| App-Store-Text und 6 Screenshots | gelesen |
| Logos, App-Icon, Launch-Bilder | nicht übernommen, Logos nicht ausgewertet |
| Dart-Code, Swift-Runner, Lern-Texte, genaue Schwellenwerte | **nicht lesbar** |

## Herkunft

- Name: Dranyen, Version 1.0.0 (Build 20), Genre Musik, gratis, Release 2026-07-02
- Bundle-ID: `net.termaheritage.dramnyenTuner`, App-ID 6783543639
- Herausgeber: Thupten Chakrishar, © 2026 Terma Heritage Foundation
- Geladen über `ipatool` aus dem App Store, also mit DRM

## Technik

- Flutter, Xcode 26.2, iOS 13.0 oder neuer, nur iPhone
- Pakete: `record` (Mikrofon), `flutter_soloud` (Audio), `wakelock_plus`,
  `package_info_plus`, `google_fonts`, `flutter_native_splash`,
  `flutter_launcher_icons`, `cupertino_icons`
- Mikrofon als einzige sensible Berechtigung
- Laut Store-Text keine Datenerfassung und vollständig offline

## Funktionen

Beobachtet aus Store-Text und Screenshots:

- **Tuner:** Automatik oder Sperre auf La, Re, So; Halbkreis-Anzeige grün/gelb/rot;
  Streifenbalken; Note in Solfège und Zahl; Hz-Anzeige; Hinweis wie „Loosen a little";
  Mikrofonpegel; Start und Stop
- **Kalibrierung:** Kammerton mit Plus/Minus, Vorgaben 432, 440 und 442 Hz,
  „Use the La I'm playing"
- **Spielen:** Holzfläche, drei Doppelsaiten, Griffe Thi, Do, Mi, Fa, So als bundlose
  Bordun-Saite, Anschlag unterhalb einer gestrichelten Linie
- **Lernen:** History & origins, The instrument, Notation, Music & genres, Sources
- **About:** Beschreibung, Anleitung, Stimmung

## Stimmung

D-Dur bei A = 440 Hz. Gemessen an den MP3-Dateien der Originalaufnahmen:

| Ton | Zahl | Note | Soll (Hz) | Gemessen (Hz) | Abweichung |
| --- | --- | --- | --- | --- | --- |
| So | 5 | A2 | 110,00 | 110,55 | +8,6 ct |
| La | 6 | B2 | 123,47 | 123,85 | +5,3 ct |
| Thi | 7 | C♯3 | 138,59 | 138,45 | −1,8 ct |
| Do | 1 | D3 | 146,83 | 146,39 | −5,3 ct |
| Re | 2 | E3 | 164,81 | 165,72 | +9,5 ct |
| Mi | 3 | F♯3 | 185,00 | 185,71 | +6,6 ct |
| Fa | 4 | G3 | 196,00 | 196,21 | +1,8 ct |

Griffe laut Screenshot: Thi und Do auf La, Mi und Fa auf Re. Die Zahl 6 für La steht im
Screenshot, die übrigen Zahlen folgen aus der Reihenfolge der Tonleiter (Annahme).

## Nachbau

**Übernommen:** Funktionsumfang, Bildschirmaufbau, musikalische Fakten, gleicher
Technik-Stack, ohne `google_fonts`, weil das Schriften zur Laufzeit lädt.

**Mit Erlaubnis übernommen** (Angabe des Projektinhabers vom 2026-11-01): die sieben
Tonaufnahmen.

**Bewusst nicht übernommen:** Code, Logos, App-Icon, Launch-Bilder,
Lern- und About-Texte und die Bundle-ID. Sie gehören dem
Herausgeber. Der Nachbau ist deshalb funktional und im Aufbau gleich, aber keine
bitgenaue Kopie.

**Stand der Prüfung:** `flutter analyze` und `flutter test` laufen unter Windows
fehlerfrei. Ein iOS-Build und ein Lauf auf einem Gerät fehlen noch, damit sind Mikrofon
und Klangausgabe ungetestet. Auf dem Gerät zuerst prüfen: Ein Referenzton von 110 Hz muss So „in tune" anzeigen. Der
Tuner rechnet fest mit 44,1 kHz. Liefert das Mikrofon 48 kHz, läge jede Anzeige um
rund 147 Cent daneben.

**Eigene Annahmen, weil der Originalcode nicht lesbar ist:** Tonerkennung (YIN),
Schwellen (grün ±5 ct, gelb ±15 ct, Anzeige ±50 ct, „a little" bis 25 ct), Farben,
Kalibrierbereich 415–466 Hz, keine Speicherung der Kalibrierung, Griffverhalten beim
Anschlagen, Schriftart Space Grotesk (nach Augenmass aus den Screenshots).
