# Test Plan — sommerhusOrden

## Unit tests

### Cottage stays
- valid date range accepted
- invalid date range rejected
- peopleCount below 1 rejected
- bedSpacesNeeded defaults to peopleCount when not explicitly set
- overlapping stays summed correctly
- week grouping works across month/year boundaries
- over-capacity detected when total > maxBedSpaces

### Inventory
- case-insensitive search
- category filtering
- status changes update timestamp
- add-to-shopping-list creates expected item

### Shopping list
- active items sort before completed
- completed items can be uncompleted
- delete confirmation behavior where applicable

## UI/manual tests
- First launch
- Empty Stugan view
- Add stay
- Edit stay
- Over-capacity warning
- Add inventory item
- Search for item
- Add item to shopping list
- Complete shopping item
- Change max bed spaces in Settings
- iCloud unavailable state

## App Store preflight
- Build Release
- Run tests
- Launch on simulator
- Launch on physical device if available
- Check privacy declarations
