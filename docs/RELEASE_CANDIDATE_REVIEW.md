# Release Candidate Review — sommerhusOrden 1.0

Datum: 2026-07-19. Granskare: Codex (fas 7-genomgång enligt promts/17).

## Status: NOT READY för App Store — READY för enhets-/TestFlight-test

Koden är komplett och verifierad lokalt. Det som återstår är uteslutande steg som
kräver Apple Developer-konto och riktiga iCloud-konton (se "Måste fixas" nedan).

## 1. Bygge och tester
- `xcodebuild … test` (iPhone 16-simulator, iOS 18.6): **TEST SUCCEEDED** —
  8 sviter, 45 testfall, 0 fel.
- `xcodebuild … -configuration Release build`: **BUILD SUCCEEDED**, 0 varningar i appkod.
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

## Måste fixas före TestFlight/App Store
1. Välj signeringsteam och verifiera CloudKit-synk + delning på riktiga enheter
   (docs/CLOUDKIT_SETUP.md §1–4).
2. Deploya CloudKit-schema till Production.
3. Publicera integritetspolicy- och support-URL; uppdatera listningen.
4. Ta skärmbilder och fyll i App Store Connect-metadata.
5. Kör docs/MANUAL_QA_CHECKLIST.md på enhet.

## Kan vänta
- Riktig appikon (platshållaren duger för TestFlight).
- UI för att hantera/avsluta delning (går via systemets iCloud-delning).
- Lokalisering till fler språk.
