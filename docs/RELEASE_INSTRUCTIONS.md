# Release-instruktioner — sommerhusOrden

## Förutsättningar
- Apple Developer-medlemskap, team valt i Xcode (se docs/CLOUDKIT_SETUP.md)
- CloudKit-schemat deployat till Production i CloudKit Console
- Integritetspolicy publicerad på offentlig URL

## Verifiera före arkivering

```bash
# Bygg + tester
xcodebuild -project sommerhusOrden.xcodeproj -scheme sommerhusOrden \
  -destination 'platform=iOS Simulator,name=iPhone 16' test

# Release-bygge (simulator, snabb kontroll)
xcodebuild -project sommerhusOrden.xcodeproj -scheme sommerhusOrden \
  -configuration Release -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Gå därefter igenom docs/MANUAL_QA_CHECKLIST.md.

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

```bash
xcodebuild -project sommerhusOrden.xcodeproj -scheme sommerhusOrden \
  -destination 'generic/platform=iOS' -archivePath build/sommerhusOrden.xcarchive archive

xcodebuild -exportArchive -archivePath build/sommerhusOrden.xcarchive \
  -exportOptionsPlist ExportOptions.plist -exportPath build/export
```

(`ExportOptions.plist` med `method: app-store-connect` skapas enklast via en första manuell export i Organizer.)

## Versionshantering
- `MARKETING_VERSION` (1.0) och `CURRENT_PROJECT_VERSION` (1) sätts i target-inställningarna.
- Bumpa build-nummer för varje TestFlight-uppladdning.
