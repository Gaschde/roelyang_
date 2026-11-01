# Roelyang Prototyp

Flutter-App für die tibetische Laute: Tuner, spielbares Instrument und kurzer Lernteil.
Sie bildet Funktionen und Aufbau von „Dranyen" nach, mit eigenem Code und eigenen
Assets. Details in [docs/ANALYSE.md](docs/ANALYSE.md).

## Web-App

**<https://gaschde.github.io/roelyang_/>**

Läuft ohne Installation im Browser auf iPhone, Android und am Computer. Das Mikrofon
muss beim ersten Start erlaubt werden. Auf dem iPhone lässt sie sich in Safari über
**Teilen → Zum Home-Bildschirm** wie eine App ablegen. Jeder Push auf `prototyp`
aktualisiert sie.

## Download

[roelyang.ipa herunterladen](https://github.com/Gaschde/roelyang_/releases/download/prototyp-latest/roelyang.ipa)
(ohne GitHub-Anmeldung)

Die IPA ist unsigniert und lässt sich nicht direkt auf dem iPhone installieren. Sie muss
zuerst mit einer eigenen Apple-ID signiert werden, zum Beispiel am PC mit Sideloadly.

## roelyang.ipa bauen

Ein iOS-Build braucht macOS und Xcode, deshalb baut GitHub Actions die IPA bei jedem
Push. Ein Push auf `prototyp` ersetzt auch den Download oben. Das Artefakt
`roelyang-ipa-unsigned` steht zusätzlich unter **Actions → Build roelyang.ipa** bereit.

## Icons neu erzeugen

```powershell
python scripts/generate_assets.py
```

Die Tonaufnahmen in `assets/audio/` stammen aus der App Dranyen der Terma Heritage
Foundation und werden mit Erlaubnis verwendet. Sie stehen nicht unter einer freien Lizenz.

## Lizenzen

Space Grotesk steht unter der SIL Open Font License, siehe `assets/fonts/OFL.txt`.
