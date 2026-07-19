# CODEX PROMPT — Phase 0–1: Project setup and local app skeleton

You are Codex acting as a senior iOS engineer.

Use the documents in `/docs` as source of truth. If docs are not yet in the repository, create them from the provided project pack before writing app code.

## Goal
Create the initial native iOS project for **sommerhusOrden** and implement a clean local MVP skeleton without CloudKit yet.

## Scope
Implement:
- Xcode project for iOS
- Swift + SwiftUI app shell
- Four tabs:
  - Stugan
  - Mat
  - Inköp
  - Inställningar
- Basic domain models:
  - CottageSettings
  - CottageStay
  - InventoryItem
  - ShoppingListItem
- Local in-memory repository or lightweight local persistence placeholder
- Swedish UI copy
- Empty states for all tabs
- Basic sample/mock data only for previews, not production state

## Important constraints
- Do not implement CloudKit in this phase.
- Do not add Firebase, Supabase, custom backend, login, analytics, ads, push notifications, barcode scanning, or AI features.
- Keep the project structure professional and App Store-ready.
- Keep dependencies minimal; prefer Apple frameworks.

## Required folders
Create a maintainable structure similar to:

```text
sommerhusOrden/
  App/
  Models/
  Persistence/
  Services/
  Views/
    Stugan/
    Mat/
    Inkop/
    Installningar/
  Components/
  Resources/
  Preview Content/
Tests/
docs/
```

## Acceptance criteria
- App launches.
- Main tab navigation works.
- Each tab has a meaningful empty state.
- Settings shows editable max bed spaces with default 10, even if changes are only local for now.
- Code compiles.
- Docs are present in `/docs`.

## Verification
Run a real build command and report exact output summary. If you cannot build because the environment lacks Xcode, say that explicitly and still ensure files/project structure are coherent.

## Report format
```markdown
## Done
- ...

## Verified
- Command: ...
- Result: ...

## Next
- Run Phase 2 prompt: cottage stays vertical slice

## Blocked
- ...
```
