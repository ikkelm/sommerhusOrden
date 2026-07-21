# Release-instruktioner — sommerhusOrden

## Förutsättningar
- Apple Developer-medlemskap. Team är redan satt i projektet (`DEVELOPMENT_TEAM = 7SZ4X2N2U7`).
- CloudKit-schemat deployat till Production i CloudKit Console (krävs för att synk
  ska fungera i TestFlight/App Store-versionen)
- Integritetspolicy publicerad på offentlig URL (färdig sida: `web/integritet.html`)

## Verifiera före arkivering

```bash
# Bygg + tester
xcodebuild -project sommerhusOrden.xcodeproj -scheme sommerhusOrden \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' test

# Release-bygge för enhet — fångar även signeringsproblem
xcodebuild -project sommerhusOrden.xcodeproj -scheme sommerhusOrden \
  -configuration Release -destination 'generic/platform=iOS' \
  -allowProvisioningUpdates build
```

Senast verifierat 2026-07-21 på Xcode 26.6: 45 tester passerar, Release-bygget
lyckas. Om den exakta simulatorn saknas, kör `xcodebuild -showdestinations -project
sommerhusOrden.xcodeproj -scheme sommerhusOrden` och välj en installerad iPhone-
eller iPad-destination. Gå därefter igenom docs/MANUAL_QA_CHECKLIST.md.

## Arkivera och ladda upp (Xcode)

1. Anslut/valj **Any iOS Device (arm64)** som destination.
2. **Product → Archive**.
3. I Organizer: **Distribute App → App Store Connect → Upload**.
   Automatisk signering; Xcode hanterar provisioneringsprofil.
4. I App Store Connect: skapa appen med bundle-id `se.mikkelwulff.sommerhusOrden`,
   fyll i metadata från docs/APP_STORE_LISTING.md, ladda upp skärmbilder,
   besvara integritetsfrågorna ("Data samlas inte in").
5. Lägg till interna TestFlight-testare (familjen) innan publik release.

## Motsvarande kommandorad (valfritt)

`ExportOptions.plist` finns i projektroten (`method: app-store-connect`, teamet ifyllt).

```bash
xcodebuild -project sommerhusOrden.xcodeproj -scheme sommerhusOrden \
  -destination 'generic/platform=iOS' -allowProvisioningUpdates \
  -archivePath build/sommerhusOrden.xcarchive archive

xcodebuild -exportArchive -archivePath build/sommerhusOrden.xcarchive \
  -exportOptionsPlist ExportOptions.plist -exportPath build/export
```

Det ger en `.ipa` i `build/export/`. Ladda upp den med appen **Transporter**
(gratis i Mac App Store) eller byt `destination` till `upload` i ExportOptions.plist
för att låta xcodebuild ladda upp direkt (kräver inloggning).

## Versionshantering
- `MARKETING_VERSION` (1.0) och `CURRENT_PROJECT_VERSION` (1) sätts i target-inställningarna.
- Bumpa build-nummer för varje TestFlight-uppladdning:

```bash
agvtool -noscm next-version -all   # kräver att du står i projektroten
```

  eller ändra `CURRENT_PROJECT_VERSION` direkt i target-inställningarna.
  `MARKETING_VERSION` (1.0) behöver bara ändras vid en ny publik version.
