# CODEX PROMPT — Phase 3: Inventory vertical slice

You are Codex acting as a senior iOS engineer.

Continue the existing **sommerhusOrden** iOS project. Use `/docs` as source of truth.

## Goal
Implement the local MVP inventory flow for fridge, freezer, pantry, household supplies, and other items.

## Functional requirements
Implement:
- Inventory list
- Add inventory item
- Edit inventory item
- Delete inventory item with confirmation
- Search inventory by item name
- Filter by category
- Change status:
  - Finns
  - Lågt
  - Slut
- Add inventory item to shopping list
- Show last updated timestamp in a subtle way

## Inventory item fields
- name: String
- category: fridge/freezer/pantry/household/other
- status: available/low/out
- quantityNote: String?
- createdAt: Date
- lastUpdatedAt: Date

## Swedish UI labels
Use Swedish labels:
- Kyl
- Frys
- Skafferi
- Hushåll
- Annat
- Finns
- Lågt
- Slut
- Lägg till i inköpslistan

## Tests
Add unit tests for:
- case-insensitive search
- category filtering
- status update changes lastUpdatedAt
- add-to-shopping-list creates expected shopping list item

## Constraints
- Do not add barcode scanning.
- Do not add AI/photo recognition.
- Do not add recipes or meal planning.
- Do not implement CloudKit yet unless previous phases already did; if so, keep compatibility.

## Acceptance criteria
- User can quickly answer “do we have oregano/milk?” via search.
- User can update stock status with low friction.
- User can add missing/low item to shopping list.
- Tests pass.
- Project builds.

## Verification
Run build and tests. Report actual commands and result.

## Report format
```markdown
## Done
- ...

## Verified
- Build: ...
- Tests: ...

## Next
- Run Phase 4 prompt: shopping list vertical slice

## Blocked
- ...
```
