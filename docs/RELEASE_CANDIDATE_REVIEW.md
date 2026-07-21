# Release Candidate Review — sommerhusOrden 1.0

Datum: 2026-07-19, omverifierad 2026-07-21. Granskare: Codex (fas 7-genomgång enligt promts/17).

## Status: NOT READY för App Store — READY för enhets-/TestFlight-test

Koden är komplett och verifierad lokalt. Det som återstår är uteslutande steg som
kräver Apple Developer-konto och riktiga iCloud-konton (se "Måste fixas" nedan).

## 1. Bygge och tester
- `xcodebuild … test` (iPhone 17 Pro Max, Xcode 26.6): **TEST SUCCEEDED** —
  8 sviter, 45 testfall, 0 fel. (Ursprungligen verifierat på Xcode 16.4; inget
  regredierade vid uppgraderingen.)
- `xcodebuild … -configuration Release -destination 'generic/platform=iOS' build`:
  **BUILD SUCCEEDED** med riktig signering, 0 varningar i appkod.
- Appen installerad och startad i simulator: kör stabilt, ingen krasch,
  iCloud-otillgängligt-läget visas korrekt utan konto.

## 2. Arkitektur
- Enkelriktat flöde: SwiftUI-vyer → `AppModel` (@Observable) → `CottageRepository`
  (protokoll) → `LocalFileCottageRepository` (JSON) + `CloudKitSyncService` (CKSyncEngine).
- Domänlogik (kapacitet, veckogruppering, filtrering, sortering) ligger i rena,
  testade structs under `Services/`.
- Inga tredjepartsberoenden. Endast Apple-ramverk.

## 3. Integritet och dataminimering
- Lagrar endast stugsamordningsdata (namn, datum, varor). Inga känsliga uppgifter.
- Ingen analys, inga annonser, inga nätverksanrop utom Apples iCloud.
- Inga hårdkodade hemligheter (grep-verifierat).

## 4. CloudKit
- Implementerat: CKSyncEngine (privat + delad databas), zon-delning via länk,
  last-writer-wins, offline-först, kontostatushantering med svensk hjälptext.
- **Ej verifierat mot riktiga konton** — miljön saknar team/iCloud. Manuella steg
  dokumenterade i docs/CLOUDKIT_SETUP.md.

## 5. App Store-checklista
Uppdaterad i docs/05_APP_STORE_CHECKLIST.md. Återstår: enhets-QA, skärmbilder,
publicerade URL:er, integritetssvar i App Store Connect.

## 6. Tillgänglighet
- Systemtypsnitt genomgående → Dynamic Type fungerar.
- Rader är kombinerade VoiceOver-element med hintar; statusmärken har etiketter;
  alla verktygsknappar använder Label.
- Färg är aldrig ensam bärare av information (Överbokat har både ikon och text).

## 7. Svensk copy
Genomgången: kort, konsekvent ("vistelse", "vara", "bocka av"), inga anglicismer.
Datumformat via systemets sv-formatterare.

## 8. Scope-kontroll
Grep-verifierat fritt från: backend, Firebase/Supabase, egen inloggning, analys,
annonser, streckkod, AI/foto, pushnotiser (endast tyst CloudKit-infrastruktur),
multi-stuga, roller, recept. Inga TODO/FIXME/HACK i koden.

## 9. Farliga antaganden
- JSON-fil som lokal lagring: rimligt för familjeskala; dokumenterat i KNOWN_LIMITATIONS.
- `settings` är en delad singleton-record: senaste skrivning vinner, dokumenterat.
- CKSyncEngine-beteende vid kontobyte: hanteras via accountChange-event (signOut
  ger "iCloud behövs"-läge); datat ligger kvar lokalt.

## Måste fixas före TestFlight
1. Deploya CloudKit-schema från Development till Production
   (docs/CLOUDKIT_SETUP.md §3). Kräver att appen kört minst en gång mot ett
   riktigt iCloud-konto så recordtyperna finns i Development.
2. Skapa appposten i App Store Connect med bundle-id `se.mikkelwulff.sommerhusOrden`.
3. Arkivera och ladda upp (docs/RELEASE_INSTRUCTIONS.md).

## Måste fixas före App Store
4. Verifiera CloudKit-synk + delning på riktiga enheter (docs/CLOUDKIT_SETUP.md §4).
   Detta är den enda helt oprövade delen av appen.
5. Publicera integritetspolicy- och support-URL (färdiga sidor i `web/`).
6. Fyll i App Store Connect-metadata från docs/APP_STORE_LISTING.md och ladda upp
   skärmbilderna i `screenshots/`.
7. Kör docs/MANUAL_QA_CHECKLIST.md på enhet.

## Avklarat sedan första granskningen
- Signeringsteam valt i projektet (`DEVELOPMENT_TEAM = 7SZ4X2N2U7`).
- Riktig appikon på plats (från logo.png).
- Release-entitlements pekar på CloudKit Production.
- `ITSAppUsesNonExemptEncryption = NO` — slipper exportfrågan vid varje uppladdning.

## Kan vänta
- UI för att hantera/avsluta delning (går via systemets iCloud-delning).
- Lokalisering till fler språk.
