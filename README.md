# Roelyang Prototyp

Flutter-App für die tibetische Laute: Tuner, spielbares Instrument und kurzer Lernteil.
Sie bildet Funktionen und Aufbau von „Dranyen" nach, mit eigenem Code und eigenen
Assets. Details in [docs/ANALYSE.md](docs/ANALYSE.md).

## Download

[roelyang.ipa herunterladen](https://github.com/Gaschde/roelyang_/releases/download/prototyp-latest/roelyang.ipa)
(ohne GitHub-Anmeldung)

Die IPA ist unsigniert und lässt sich nicht direkt auf dem iPhone installieren. Sie muss
zuerst mit einer eigenen Apple-ID signiert werden, zum Beispiel am PC mit Sideloadly.

## roelyang.ipa bauen

Ein iOS-Build braucht macOS und Xcode, deshalb baut GitHub Actions die IPA bei jedem
Push. Ein Push auf `prototyp` ersetzt auch den Download oben. Das Artefakt
`roelyang-ipa-unsigned` steht zusätzlich unter **Actions → Build roelyang.ipa** bereit.

## Assets neu erzeugen

```powershell
python scripts/generate_assets.py
```

Die Klänge sind synthetisiert und gelten nur als Platzhalter. Echte Aufnahmen kommen
als `assets/audio/<ton>.wav` mit denselben Namen hinein.

## Lizenzen

Space Grotesk steht unter der SIL Open Font License, siehe `assets/fonts/OFL.txt`.
