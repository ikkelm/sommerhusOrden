# CloudKit Sync Rules — sommerhusOrden

## Sharing model
MVP assumes a small trusted family group. All members can edit all shared records.

## Conflict rules
- Prefer last-writer-wins for simple fields in MVP.
- Preserve record IDs to avoid duplicates.
- Use updatedAt for UI clarity.
- Avoid complex merge UI in MVP.

## Offline behavior
- App should remain usable offline with cached/local data.
- Changes should sync when iCloud becomes available.
- If sync state is uncertain, show a simple non-alarming message.

## iCloud account unavailable
Show message:
"iCloud behövs för att synka med familjen. Du kan fortfarande se lokala data om de finns på enheten."

## Data minimization
Store only practical cottage coordination data. Do not store sensitive personal data beyond family/group names and stay details.
