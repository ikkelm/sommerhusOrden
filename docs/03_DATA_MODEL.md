# Data Model — sommerhusOrden

## CottageSettings
Represents shared settings.

Fields:
- id: UUID
- cottageName: String, default "Sommerhuset"
- maxBedSpaces: Int, default 10
- updatedAt: Date

## CottageStay
Represents one family/group stay.

Fields:
- id: UUID
- familyName: String
- arrivalDate: Date
- departureDate: Date
- peopleCount: Int
- bedSpacesNeeded: Int? optional; default to peopleCount in MVP unless future sleeping arrangements need different value
- note: String?
- createdAt: Date
- updatedAt: Date

Rules:
- departureDate must be same day or after arrivalDate
- peopleCount must be >= 1
- bedSpacesNeeded, if present, must be >= 1
- UI should clearly communicate whether departure day is included or not; recommended: hotel-style nights, arrival included, departure not included

## InventoryItem
Fields:
- id: UUID
- name: String
- category: InventoryCategory
- status: InventoryStatus
- quantityNote: String?
- lastUpdatedAt: Date
- createdAt: Date

InventoryCategory:
- fridge
- freezer
- pantry
- household
- other

InventoryStatus:
- available
- low
- out

## ShoppingListItem
Fields:
- id: UUID
- name: String
- quantityNote: String?
- category: InventoryCategory?
- isCompleted: Bool
- createdAt: Date
- updatedAt: Date

## Derived calculations
- bedSpacesUsed(for date range)
- overCapacity dates/weeks
- grouped stays by calendar week
- inventory search by localized case-insensitive name
- active shopping items before completed items
