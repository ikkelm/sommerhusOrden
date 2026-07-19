# CODEX PROMPT — Phase 5: CloudKit/iCloud sync

You are Codex acting as a senior iOS engineer with CloudKit experience.

Continue the existing **sommerhusOrden** iOS project. Use `/docs` as source of truth.

## Goal
Add Apple-native iCloud/CloudKit sync so the family can share cottage stays, inventory, shopping list, and settings across devices.

## Product rule
MVP uses a trusted small family group:
- all members can edit everything
- no role-based permissions
- no custom login
- no custom backend

## Required work
- Configure the project for iCloud/CloudKit capabilities.
- Choose a CloudKit-compatible persistence approach.
- Keep repository/persistence abstraction clean.
- Sync these data types:
  - CottageSettings
  - CottageStay
  - InventoryItem
  - ShoppingListItem
- Handle iCloud unavailable state gracefully.
- Preserve offline usability where reasonable.
- Document any manual Xcode/Apple Developer Portal steps that cannot be automated.

## Conflict handling
Use simple MVP rules:
- last-writer-wins for simple fields
- stable UUID/record identity to prevent duplicates
- updatedAt timestamps for clarity
- no complex merge UI in MVP

## UI requirements
- Settings should show a concise sync/iCloud status/help section.
- If iCloud is unavailable, show:
  “iCloud behövs för att synka med familjen. Du kan fortfarande se lokala data om de finns på enheten.”

## Tests/verification
- Keep unit tests passing.
- Add tests around repository behavior where practical.
- If CloudKit cannot be fully tested in the current environment, clearly state what was verified and what requires physical devices/Apple Developer setup.

## Constraints
- Do not add Firebase/Supabase/backend.
- Do not add account/password login.
- Do not add push notifications.
- Do not weaken privacy posture.

## Acceptance criteria
- App remains functional locally.
- Sync architecture is implemented or clearly staged behind documented manual CloudKit setup.
- User-facing iCloud errors are understandable.
- Project builds.
- Documentation updated.

## Verification
Run build and tests. Report actual commands and result.

## Report format
```markdown
## Done
- ...

## Verified
- Build: ...
- Tests: ...
- CloudKit/manual setup status: ...

## Next
- Run Phase 6 prompt: polish and App Store readiness

## Blocked
- ...
```
