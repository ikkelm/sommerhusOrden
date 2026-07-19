# MASTER PROMPT FOR CODEX — sommerhusOrden

You are Codex acting as a senior iOS engineer, product-minded technical lead, and App Store release engineer.

Build a professional native iOS app named **sommerhusOrden**.

## Product summary
The app is for a small group of close family members who share access to a cottage/summer house. The app has two main purposes:

1. **Cottage occupancy planning**
   - Show which families are staying in the cottage, during which dates/weeks.
   - Show how many people/bed spaces each family needs for each stay.
   - Compare total booked bed spaces against a configurable maximum.
   - Default maximum bed spaces: **10**.
   - All family members can edit everything.
   - A family booking must allow entering how many people are actually coming; not everyone in a family is always present.

2. **Food and shopping coordination**
   - Track what exists in the fridge, freezer, pantry, and household supplies.
   - Allow quick search, e.g. “oregano” or “milk”.
   - Maintain a shared shopping list.
   - Allow inventory items to be marked as available, low, or out.
   - Allow items to be moved/added to the shopping list.

The app must sync across devices for the invited family members.

## Core technical direction
Use:
- Swift
- SwiftUI
- CloudKit / iCloud sharing for sync
- XCTest for tests

Avoid a custom backend in MVP. Do not introduce Firebase, Supabase, web backend, account/password login, or server infrastructure unless explicitly requested later.

## Product constraints
- MVP must be small enough to complete and ship.
- Design for App Store release from the beginning.
- Swedish UI copy in version 1 unless Mikkel later asks otherwise.
- The app should be usable by non-technical family members.
- Support offline use with sync when iCloud is available again.
- All family members can edit all shared data.
- No sensitive tracking, ads, analytics, or unnecessary personal data collection.

## Required project files
Create and maintain these documentation files in the repository:

```text
/docs/PRODUCT_REQUIREMENTS.md
/docs/TECHNICAL_ARCHITECTURE.md
/docs/DATA_MODEL.md
/docs/UI_FLOWS.md
/docs/APP_STORE_CHECKLIST.md
/docs/TEST_PLAN.md
/docs/CLOUDKIT_SYNC_RULES.md
/docs/PRIVACY_POLICY.md
/docs/DEFINITION_OF_DONE.md
```

Use the planning documents from this pack as the source of truth.

## Expected implementation approach
1. Create a clean Xcode iOS project.
2. Implement the domain model.
3. Implement local data first if useful, but keep CloudKit sync architecture in mind from the start.
4. Add CloudKit sync/sharing.
5. Build the SwiftUI UI in focused vertical slices.
6. Add tests for date overlap, bed-space totals, inventory search, and shopping-list behavior.
7. Prepare App Store metadata/checklist.
8. Keep the app simple, reliable, and maintainable.

## Key MVP screens
- Dashboard / Stugan overview
- Add/edit cottage stay
- Family/stay list by week
- Inventory search/list
- Add/edit inventory item
- Shopping list
- Settings

## Important implementation rules
- Do not overbuild.
- Do not add authentication beyond iCloud/CloudKit sharing in MVP.
- Do not add push notifications in MVP.
- Do not add barcode scanning in MVP.
- Do not add AI/photo recognition in MVP.
- Do not add multi-cottage support in MVP.
- Do not add Android/web support in MVP.
- Keep dependencies minimal.
- Prefer Apple-native frameworks.
- Verify the app builds before reporting completion.

## Communication format back to Mikkel
When reporting progress, use:

```markdown
## Done
- ...

## Verified
- Build/test command and result

## Next
- One concrete next step

## Blocked
- Only if something truly blocks progress
```

Never claim the project builds or tests pass unless you actually ran the build/tests.
