# Product Requirements — sommerhusOrden

## Vision
`sommerhusOrden` helps a close family coordinate practical cottage use without chats, guesswork, or duplicate shopping.

## Users
- Mikkel
- Close family members
- Non-technical users
- All users have equal permissions in MVP

## MVP goals
1. Everyone can see who is in the cottage and when.
2. Everyone can see whether planned stays exceed available bed capacity.
3. Everyone can check what food/supplies exist in the cottage.
4. Everyone can maintain a shared shopping list.
5. Changes sync across devices.
6. The app is structured for App Store release.

## Out of scope for MVP
- Role-based permissions
- Custom login system
- Custom backend
- Push notifications
- Barcode scanning
- Receipt scanning
- AI/photo fridge recognition
- Multiple cottages
- Android/web app
- Complex booking approval workflow

## Functional requirements

### Cottage stays
- Create stay
- Edit stay
- Delete stay after user confirmation
- Fields:
  - family/group name
  - arrival date
  - departure date
  - number of people/bed spaces needed for this specific stay
  - optional note
- Show stays by date/week
- Show total bed spaces used per day/week
- Warn if total exceeds max bed spaces
- Max bed spaces defaults to 10 and can be changed in Settings

### Inventory
- Create item
- Edit item
- Mark as available / low / out
- Categorize item:
  - Fridge
  - Freezer
  - Pantry
  - Household
  - Other
- Search items by name
- Show last updated timestamp
- Add inventory item to shopping list

### Shopping list
- Add item
- Edit item
- Mark completed
- Unmark completed
- Delete completed or individual item
- Optional quantity/note
- Category optional

### Settings
- Cottage name
- Max bed spaces, default 10
- Manage visible family/group names, if implemented simply
- iCloud sync status/help text

## Non-functional requirements
- Fast launch
- Simple Swedish copy
- Works reasonably offline
- No analytics/ads
- Accessible Dynamic Type support
- App Store compatible privacy posture
