# Skärmbilder för App Store

Tagna 2026-07-21. Statusfältet är satt till Apples kanoniska 09:41 via
`simctl status_bar override`.

Appen är universell (`TARGETED_DEVICE_FAMILY = "1,2"`), så App Store Connect
kräver **två** storlekar: iPhone 6.9" och iPad 13". Båda finns här.

## iPhone — 1320×2868 (iPhone 17 Pro Max, 6.9")

| Fil | Visar | Klar att ladda upp |
|---|---|---|
| `01-stugan.png` | Veckoöversikt med kapacitetsvarning ("Överbokat") | Ja |
| `02-vistelse.png` | Vistelseformuläret med hotellnätter-förklaringen | Ja |
| `03-mat.png` | Förrådet med sökfält, kategorifilter och statusmärken | Ja |
| `04-inkop.png` | Inköpslistan grupperad per kategori, med avbockade varor | Ja |
| `05-installningar-EJ-KLAR.png` | Inställningar | **Nej** — se nedan |

## iPad — 2064×2752 (iPad Pro 13", M5)

| Fil | Visar | Klar att ladda upp |
|---|---|---|
| `ipad-01-stugan.png` | Hela veckoöversikten, inkl. "Som mest 12 av 10 sängplatser" | Ja |
| `ipad-02-mat.png` | Hela förrådet i ett svep | Ja |
| `ipad-03-inkop.png` | Inköpslistan | Ja |

## Varför bild 5 inte duger

Simulatorn är inte inloggad på iCloud, så Inställningar visar rutan
"iCloud behövs för att synka med familjen" och knappen **Dela med familjen**
saknas helt. Som butiksbild ser det ut som ett fel.

Ta om den på en riktig enhet med iCloud inloggat, antingen på Inställningar-fliken
eller — bättre — på systemets delningsvy som öppnas via **Dela med familjen**.
Det är den bild som säljer appens poäng.

Antalet räcker: App Store kräver minst en bild per storlek, max tio.

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

xcrun simctl status_bar "$SIM" override --time "9:41" \
  --batteryState charged --batteryLevel 100 --wifiMode active --wifiBars 3
xcrun simctl launch "$SIM" se.mikkelwulff.sommerhusOrden

xcrun simctl io "$SIM" screenshot screenshots/01-stugan.png
```

Byt flik i simulatorn för hand mellan bilderna och kör `simctl io … screenshot` igen.
Samma recept för iPad — byt bara ut simulatornamnet mot `iPad Pro 13-inch`.
