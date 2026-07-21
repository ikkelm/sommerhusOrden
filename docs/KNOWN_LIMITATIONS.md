# Kända begränsningar — sommerhusOrden 1.0

Ärlig lista, medvetna MVP-avgränsningar och saker som kräver verklig miljö.

## Kräver verklig miljö (inte verifierat i utvecklingsmiljön)
- **CloudKit-synk är obeprövad mot riktiga iCloud-konton.** Koden är komplett
  (CKSyncEngine, delning, konflikthantering) och bygger signerat, men har inte kunnat
  köras mot iCloud eftersom simulatorn saknar iCloud-inloggning.
  Måste testas enligt docs/CLOUDKIT_SETUP.md §4 innan App Store-release.
- CloudKit-schemat måste deployas till Production manuellt före App Store-release.

## Medvetna MVP-avgränsningar
- Delningen omfattar hela stugan (zonen) — ingen granulär behörighet; alla inbjudna
  kan redigera allt (per produktkrav).
- Deltagare hanteras via systemets delnings-UI (UICloudSharingController) under
  "Dela med familjen": bjuda in, ta bort deltagare och avsluta delning.
  Standard är privat delning (endast inbjudna). API:t är mjukt utfasat av Apple
  sedan iOS 17 men fullt fungerande; kan bytas mot ShareLink-flödet senare.
- Konflikter löses med last-writer-wins per post; samtidiga redigeringar av samma
  post kan skriva över varandras fält (acceptabelt för liten betrodd familj).
- Inställningar (stugans namn, max sängplatser) är en enda delad post — senaste
  ändring vinner.
- Ingen historik/ångra-funktion utöver systemets vanliga beteenden.
- Veckoöversikten visar bara veckor som har vistelser (inga tomma veckor).
- Sökning gäller varunamn, inte anteckningar.
- Endast svenska; ingen lokalisering till andra språk i 1.0.

## Tekniska noteringar
- Lokal lagring är en JSON-fil (Application Support). Robust för familjedata i
  denna storlek; inte byggd för tusentals poster.
- `aps-environment` är satt till `development`; Xcode/App Store hanterar
  production-värdet automatiskt vid distribution.
- Tester körs utan CloudKit (synk inaktiveras under XCTest).
