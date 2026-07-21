# Skärmbilder för App Store

Tagna 2026-07-21 på **iPhone 17 Pro Max-simulator, 1320×2868 px** — Apples
6.9"-format, vilket är den enda storlek som krävs för en iPhone-only-app.
App Store Connect skalar ner till mindre format automatiskt.

| Fil | Visar | Klar att ladda upp |
|---|---|---|
| `01-stugan.png` | Veckoöversikt med kapacitetsvarning ("Överbokat") | Ja |
| `02-vistelse.png` | Vistelseformuläret med hotellnätter-förklaringen | Ja |
| `03-mat.png` | Förrådet med sökfält, kategorifilter och statusmärken | Ja |
| `04-inkop.png` | Inköpslistan grupperad per kategori, med avbockade varor | Ja |
| `05-installningar-EJ-KLAR.png` | Inställningar | **Nej** — se nedan |

## Varför bild 5 inte duger

Simulatorn är inte inloggad på iCloud, så Inställningar visar rutan
"iCloud behövs för att synka med familjen" och knappen **Dela med familjen**
saknas helt. Som butiksbild ser det ut som ett fel.

Ta om den på en riktig enhet med iCloud inloggat, antingen på Inställningar-fliken
eller — bättre — på systemets delningsvy som öppnas via **Dela med familjen**.
Det är den bild som säljer appens poäng.

Fyra bilder räcker gott för inlämning; App Store kräver minst en.

## Ta om bilderna

Demodatat genereras av `scripts/seed_screenshot_data.py`. Datumen är relativa till
dagens datum, så bilderna blir aldrig inaktuella.

```bash
SIM=$(xcrun simctl list devices available | grep "iPhone 17 Pro Max" | grep -o "[0-9A-F-]\{36\}" | head -1)
xcrun simctl boot "$SIM"; open -a Simulator

xcodebuild -project sommerhusOrden.xcodeproj -scheme sommerhusOrden \
  -destination "platform=iOS Simulator,id=$SIM" build

APP=$(find ~/Library/Developer/Xcode/DerivedData/sommerhusOrden-*/Build/Products/Debug-iphonesimulator -name "sommerhusOrden.app" | head -1)
xcrun simctl install "$SIM" "$APP"
xcrun simctl launch "$SIM" se.mikkelwulff.sommerhusOrden   # skapar datamappen
xcrun simctl terminate "$SIM" se.mikkelwulff.sommerhusOrden

CONTAINER=$(xcrun simctl get_app_container "$SIM" se.mikkelwulff.sommerhusOrden data)
python3 scripts/seed_screenshot_data.py "$CONTAINER/Library/Application Support/sommerhusOrden/store.json"
xcrun simctl launch "$SIM" se.mikkelwulff.sommerhusOrden

xcrun simctl io "$SIM" screenshot screenshots/01-stugan.png
```

Byt flik i simulatorn för hand mellan bilderna och kör `simctl io … screenshot` igen.
