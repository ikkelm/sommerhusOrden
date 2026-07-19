# sommerhusOrden — Codex Project Pack

This pack contains the planning and implementation instructions for building the iOS app `sommerhusOrden`.

Primary recipient: Mikkel Wulff <mikkelwulff@gmail.com>

## Goal
Build a polished native iOS app for close family members to coordinate cottage occupancy, bed capacity, pantry/fridge inventory, and shopping lists — with sync across family devices and a realistic path to App Store release.

## Recommended stack
- Swift
- SwiftUI
- SwiftData where suitable
- CloudKit / iCloud for sync and sharing
- XCTest
- Xcode project ready for App Store distribution

## Use order
1. Start with `00_MASTER_PROMPT.md`.
2. Give Codex the project docs `01`–`10`.
3. Then run the phase prompts in order:
   - `11_CODEX_PROMPT_PHASE_0_1_PROJECT_SETUP.md`
   - `12_CODEX_PROMPT_PHASE_2_COTTAGE_STAYS.md`
   - `13_CODEX_PROMPT_PHASE_3_INVENTORY.md`
   - `14_CODEX_PROMPT_PHASE_4_SHOPPING_LIST.md`
   - `15_CODEX_PROMPT_PHASE_5_CLOUDKIT_SYNC.md`
   - `16_CODEX_PROMPT_PHASE_6_APP_STORE_POLISH.md`
   - `17_CODEX_PROMPT_PHASE_7_RELEASE_CANDIDATE.md`
4. Keep `18_CODEX_OPERATING_RULES.md` as standing instructions.

## Files
- `00_MASTER_PROMPT.md` — paste this into Codex first
- `01_PRODUCT_REQUIREMENTS.md` — product scope and MVP
- `02_TECHNICAL_ARCHITECTURE.md` — architecture and stack decisions
- `03_DATA_MODEL.md` — entities and relationships
- `04_UI_FLOWS.md` — main screens and flows
- `05_APP_STORE_CHECKLIST.md` — App Store readiness checklist
- `06_IMPLEMENTATION_PLAN.md` — phased work plan for Codex
- `07_TEST_PLAN.md` — test strategy
- `08_CLOUDKIT_SYNC_RULES.md` — sync and conflict rules
- `09_PRIVACY_POLICY_DRAFT.md` — draft privacy policy text
- `10_DEFINITION_OF_DONE.md` — acceptance criteria
- `11`–`17` — executable Codex phase prompts
- `18_CODEX_OPERATING_RULES.md` — standing rules to prevent scope creep
- `19_EMAIL_BODY.md` — email text for sending the package
