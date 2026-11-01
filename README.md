# Roelyang Prototyp

Flutter-App für die tibetische Laute: Tuner, spielbares Instrument und kurzer Lernteil.
Sie bildet Funktionen und Aufbau von „Dranyen" nach, mit eigenem Code und eigenen
Assets. Details in [docs/ANALYSE.md](docs/ANALYSE.md).

## roelyang.ipa bauen

Ein iOS-Build braucht macOS und Xcode, deshalb baut GitHub Actions die IPA:

```powershell
git init -b main
git add .
git commit -m "Roelyang Prototyp"
git remote add origin https://github.com/DEIN-NAME/roelyang_prototyp.git
git push -u origin main
```

Danach unter **Actions → Build roelyang.ipa** den Lauf abwarten und das Artefakt
`roelyang-ipa-unsigned` herunterladen.

Die IPA ist unsigniert. Installieren lässt sie sich mit deiner eigenen Apple-ID, zum
Beispiel über Sideloadly oder AltStore.

## Assets neu erzeugen

```powershell
python scripts/generate_assets.py
```

Die Klänge sind synthetisiert und gelten nur als Platzhalter. Echte Aufnahmen kommen
als `assets/audio/<ton>.wav` mit denselben Namen hinein.

## Lizenzen

Space Grotesk steht unter der SIL Open Font License, siehe `assets/fonts/OFL.txt`.
