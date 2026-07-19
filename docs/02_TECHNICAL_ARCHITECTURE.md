# Technical Architecture — sommerhusOrden

## Platform
Native iOS app using Swift and SwiftUI.

## Sync
Use CloudKit/iCloud as the sync layer. Prefer Apple-native sync and sharing to avoid custom backend maintenance.

## Suggested architecture
- SwiftUI views
- ViewModels or Observable models where appropriate
- Repository layer for persistence/sync abstraction
- Domain services for calculations:
  - date/week grouping
  - bed capacity totals
  - search/filtering

## Suggested modules/folders
```text
sommerhusOrden/
  App/
  Models/
  Persistence/
  CloudKit/
  Services/
  Views/
    Dashboard/
    Stays/
    Inventory/
    Shopping/
    Settings/
  Components/
  Resources/
  Tests/
```

## Data storage approach
Use CloudKit-compatible persistence. If using SwiftData, confirm CloudKit compatibility and project entitlements early. If CloudKit sharing complexity becomes high, implement a clean repository layer so the persistence implementation can evolve without rewriting UI.

### Implemented approach (as built)
- Local truth: JSON file in Application Support via `LocalFileCottageRepository`
  behind the `CottageRepository` protocol. Fully offline-capable.
- Sync: `CloudKitSyncService` built on `CKSyncEngine` (iOS 17+), one engine for the
  private database and one for the shared database. Records live in the custom zone
  `SommerhusZone`; the whole zone is shared with the family via a zone-wide `CKShare`.
- Conflicts: last-writer-wins via `updatedAt`/`lastUpdatedAt`; stable UUID-based
  record names prevent duplicates. See `docs/CLOUDKIT_SETUP.md` for manual setup steps.

## CloudKit principles
- Use iCloud account as identity.
- All shared family members can edit all records in MVP.
- Avoid storing sensitive personal data.
- Keep records small and simple.
- Handle unavailable iCloud gracefully.

## Security/privacy
- No ads
- No third-party analytics
- No unnecessary network calls
- No hardcoded secrets
- No custom password storage

## App Store readiness
- Bundle ID set correctly
- iCloud capability enabled
- Privacy manifest and privacy policy prepared
- App icon and screenshots prepared before submission
