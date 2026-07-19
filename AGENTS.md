# sommerhusOrden — Agent/Codex Instructions

You are working on `sommerhusOrden`, a native iOS app for family cottage coordination.

## Source of truth

Read these before coding:

- `00_MASTER_PROMPT.md`
- `01_PRODUCT_REQUIREMENTS.md`
- `02_TECHNICAL_ARCHITECTURE.md`
- `03_DATA_MODEL.md`
- `04_UI_FLOWS.md`
- `10_DEFINITION_OF_DONE.md`
- `18_CODEX_OPERATING_RULES.md`

If the files are sorted into folders, use:

- `docs/00_MASTER_PROMPT.md`
- `docs/01_PRODUCT_REQUIREMENTS.md`
- `docs/02_TECHNICAL_ARCHITECTURE.md`
- `docs/03_DATA_MODEL.md`
- `docs/04_UI_FLOWS.md`
- `docs/10_DEFINITION_OF_DONE.md`
- `prompts/18_CODEX_OPERATING_RULES.md`

## Build approach

Work phase-by-phase. Do not jump ahead.

Recommended order:

1. `11_CODEX_PROMPT_PHASE_0_1_PROJECT_SETUP.md`
2. `12_CODEX_PROMPT_PHASE_2_COTTAGE_STAYS.md`
3. `13_CODEX_PROMPT_PHASE_3_INVENTORY.md`
4. `14_CODEX_PROMPT_PHASE_4_SHOPPING_LIST.md`
5. `15_CODEX_PROMPT_PHASE_5_CLOUDKIT_SYNC.md`
6. `16_CODEX_PROMPT_PHASE_6_APP_STORE_POLISH.md`
7. `17_CODEX_PROMPT_PHASE_7_RELEASE_CANDIDATE.md`

If the files are sorted into folders, use the same files under `prompts/`.

## Hard constraints

- Swift + SwiftUI native iOS.
- CloudKit/iCloud sync for MVP.
- No custom backend in MVP.
- Swedish UI copy.
- All family members can edit everything.
- Default max bed spaces: 10, editable in settings.
- Booking is per family/group, with number of people actually coming per stay.
- No analytics.
- No ads.
- No barcode scanning in MVP.
- No AI/photo recognition in MVP.
- No recipes in MVP.
- No Android/web in MVP.
- No role permissions in MVP.
- No multiple cottages in MVP.

## Product intent

The app should help a small trusted family coordinate use of a shared summer house.

MVP areas:

1. Cottage stays / booking weeks.
2. Actual number of people coming per family/group.
3. Bed-space visibility against configurable max capacity.
4. Food/inventory basics.
5. Shared shopping list.
6. Settings for max bed spaces.

## Scope brake

Do not expand scope just because a feature is interesting.

Before adding anything not explicitly in the docs, ask whether it is needed for MVP. If not, write it under “Later / Not now” instead of implementing it.

## Quality bar

- Keep the app simple and maintainable.
- Prefer boring native SwiftUI patterns.
- Keep model/data logic testable.
- Include empty states and basic error states.
- Avoid hardcoded secrets or private identifiers.
- Do not report “done” unless a real build/test has run, or the environment limitation is stated clearly.

## Current first task

Start with:

```text
11_CODEX_PROMPT_PHASE_0_1_PROJECT_SETUP.md
```

Goal of first phase:

- create/open the native iOS project structure
- add core models
- add SwiftUI app shell
- add tabs/navigation
- keep data local/in-memory or local persistence first
- do not start CloudKit yet

CloudKit comes later, after the local app skeleton and core flows are working.
