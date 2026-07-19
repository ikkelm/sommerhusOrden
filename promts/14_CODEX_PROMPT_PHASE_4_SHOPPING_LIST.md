# CODEX PROMPT — Phase 4: Shopping list vertical slice

You are Codex acting as a senior iOS engineer.

Continue the existing **sommerhusOrden** iOS project. Use `/docs` as source of truth.

## Goal
Implement the local MVP shared shopping list flow.

## Functional requirements
Implement:
- Add shopping item quickly
- Edit shopping item
- Mark item completed
- Unmark completed item
- Delete item with confirmation or swipe action
- Optional quantity/note field
- Optional category field using the same categories as inventory
- Active items shown before completed items
- Completed section can be visually quieter or collapsible

## Shopping item fields
- name: String
- quantityNote: String?
- category: InventoryCategory?
- isCompleted: Bool
- createdAt: Date
- updatedAt: Date

## UX requirements
- Adding an item should require minimal taps.
- Empty state should explain what the list is for.
- Completing an item should feel like a normal checklist.
- Avoid complex grocery-store aisle logic in MVP.

## Tests
Add unit tests for:
- adding item
- active before completed sorting
- completing and uncompleting item
- deleting item
- inventory-to-shopping-list integration if not already tested

## Constraints
- Do not add recipes.
- Do not add meal plans.
- Do not add store-specific sorting.
- Do not add push notifications.

## Acceptance criteria
- Shopping list is usable as a normal shared grocery list locally.
- Inventory can send items to shopping list.
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
- Run Phase 5 prompt: CloudKit sync

## Blocked
- ...
```
