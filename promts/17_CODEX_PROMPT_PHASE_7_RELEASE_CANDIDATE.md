# CODEX PROMPT — Phase 7: Release candidate review

You are Codex acting as a senior iOS release engineer and strict code reviewer.

Continue the existing **sommerhusOrden** iOS project. Use `/docs` as source of truth.

## Goal
Perform a final release-candidate quality pass before TestFlight/App Store submission.

## Required review areas
1. Build and tests
2. App architecture sanity
3. Privacy and data minimization
4. CloudKit/iCloud behavior and documented manual steps
5. App Store checklist
6. Accessibility basics
7. Swedish UI copy
8. Scope creep check
9. Dangerous assumptions or hidden TODOs
10. Release notes and known limitations

## Required commands
Run whatever commands are appropriate for the project, typically:
- build command
- test command
- lint/format command if configured

Do not claim success unless commands actually ran.

## Scope creep removal
Remove or disable any accidental MVP-excluded features:
- custom backend
- custom login
- analytics
- ads
- barcode scanning
- AI/photo recognition
- push notifications
- multi-cottage support
- role permissions
- recipes/meal planning

## Required output artifacts
Create/update:
- `/docs/RELEASE_CANDIDATE_REVIEW.md`
- `/docs/KNOWN_LIMITATIONS.md`
- `/docs/APP_STORE_SUBMISSION_NOTES.md`

## Acceptance criteria
- Build passes or blocker is explicit.
- Tests pass or failing tests are listed with exact failure.
- No MVP-excluded features are present.
- App Store submission notes exist.
- Known limitations are honest and concise.

## Report format
```markdown
## Release Candidate Status
One of: READY / NOT READY

## Done
- ...

## Verified
- Build: ...
- Tests: ...

## Must fix before TestFlight/App Store
- ...

## Safe to defer
- ...
```
