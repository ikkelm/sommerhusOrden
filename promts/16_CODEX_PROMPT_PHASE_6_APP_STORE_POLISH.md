# CODEX PROMPT — Phase 6: Polish and App Store readiness

You are Codex acting as a senior iOS release engineer and product-quality reviewer.

Continue the existing **sommerhusOrden** iOS project. Use `/docs` as source of truth.

## Goal
Prepare the app for TestFlight/App Store readiness without expanding MVP scope.

## Required work
- Accessibility pass:
  - Dynamic Type
  - VoiceOver labels for important controls
  - sufficient contrast
- Empty states and error states polish
- Swedish copy pass: concise and natural
- App icon placeholder if no final icon exists
- Launch screen check
- Privacy policy document finalized enough for review by Mikkel
- App Store checklist updated
- Store listing draft:
  - subtitle
  - short description
  - longer description
  - keywords
  - support/privacy URL placeholders
- Manual QA checklist
- Release build/archive instructions

## App Store positioning
If needed, frame the app generally as:
“A family cottage coordination app for shared stays, pantry inventory, and shopping lists.”
Do not frame it as useful only to one named family.

## Constraints
- Do not add new major features.
- Do not add analytics.
- Do not add ads.
- Do not add backend.
- Do not add paid features.

## Acceptance criteria
- App feels coherent and non-prototype-like.
- App Store checklist is updated with actual status.
- Store metadata draft exists.
- Project builds.
- Tests pass.

## Verification
Run build and tests. If archive validation is possible, run it or document exact manual steps.

## Report format
```markdown
## Done
- ...

## Verified
- Build: ...
- Tests: ...
- App Store readiness: ...

## Next
- Run Phase 7 prompt: release candidate review

## Blocked
- ...
```
