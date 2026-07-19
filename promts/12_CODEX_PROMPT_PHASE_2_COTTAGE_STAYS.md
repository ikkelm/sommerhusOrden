# CODEX PROMPT — Phase 2: Cottage stays vertical slice

You are Codex acting as a senior iOS engineer.

Continue the existing **sommerhusOrden** iOS project. Use `/docs` as source of truth.

## Goal
Implement the complete local MVP flow for planning who is in the cottage and whether bed capacity is exceeded.

## Functional requirements
Implement:
- Create cottage stay
- Edit cottage stay
- Delete cottage stay with confirmation
- List stays by upcoming date and/or week
- Week overview showing:
  - week number/date range
  - family/group names
  - number of people coming for each stay
  - total people/bed spaces used
  - max bed spaces
  - clear warning when total exceeds max
- Settings max bed spaces default 10 and editable

## Stay fields
- familyName: String
- arrivalDate: Date
- departureDate: Date
- peopleCount: Int
- optional bedSpacesNeeded, default same as peopleCount unless UI supports separate advanced field
- optional note

## Date rule
Use hotel-style date intervals:
- arrival date included
- departure date not included
Example: Friday to Sunday means Friday night and Saturday night.
Document this in code comments and UI helper text if needed.

## Validation
- familyName required
- arrivalDate must be before or equal to departureDate depending on chosen UI, but avoid zero-night confusing stays unless explicitly supported
- peopleCount >= 1
- maxBedSpaces >= 1

## Tests
Add unit tests for:
- valid stay creation
- invalid peopleCount
- invalid date range
- overlapping stays summed correctly
- over-capacity detection
- week grouping across month/year boundary if practical

## Constraints
- Do not implement CloudKit yet.
- Do not add role permissions.
- Do not add approval workflow.
- Do not add calendar export.

## Acceptance criteria
- User can manage stays locally.
- User can see if a week/day is over capacity.
- Tests cover the core calculation logic.
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
- Run Phase 3 prompt: inventory vertical slice

## Blocked
- ...
```
