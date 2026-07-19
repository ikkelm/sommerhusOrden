# Implementation Plan — sommerhusOrden

## Phase 0 — Repository setup
- Create Xcode project
- Add docs folder with planning files
- Configure git
- Keep dependencies minimal

## Phase 1 — Local MVP skeleton
- App shell with four tabs
- Models
- In-memory or local persistence prototype
- Basic UI for all main flows

## Phase 2 — Cottage stays vertical slice
- Create/edit/delete stays
- Week overview
- People/bed-space totals
- Over-capacity warning
- Tests for date ranges and capacity

## Phase 3 — Inventory vertical slice
- Create/edit items
- Category/status
- Search
- Add item to shopping list
- Tests for search/filtering

## Phase 4 — Shopping list vertical slice
- Add/edit/complete/delete items
- Grouping/sorting
- Tests for completion/sorting

## Phase 5 — CloudKit sync
- Configure entitlements
- Implement shared sync
- Handle iCloud unavailable
- Test on at least two devices/simulators/accounts if possible

## Phase 6 — Polish and App Store readiness
- Accessibility pass
- Empty/error states
- App icon placeholder/final
- Privacy policy
- Screenshots
- Archive build

## Phase 7 — Release candidate
- Run full tests
- Manual QA checklist
- Archive validation
- Prepare TestFlight/App Store submission
