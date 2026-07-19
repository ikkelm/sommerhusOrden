# UI Flows — sommerhusOrden

## Main tabs
1. Stugan
2. Mat
3. Inköp
4. Inställningar

## Stugan tab
Purpose: show who is staying and whether beds are enough.

Recommended layout:
- Top summary card:
  - Cottage name
  - Next stay
  - Current max bed spaces
- Week list:
  - Week number/date range
  - Families staying
  - People/bed spaces used / max
  - Red/orange warning if over capacity
- Add stay button

## Add/edit stay
Fields:
- Familj/grupp
- Ankomst
- Avresa
- Antal personer som kommer
- Sängplatser som behövs, optional advanced field; default same as people count
- Anteckning

Validation:
- Require familyName
- Require valid date range
- Require peopleCount >= 1

## Mat tab
Purpose: answer “do we have X?” quickly.

Recommended layout:
- Search field
- Category filter chips
- Item rows:
  - name
  - category
  - status
  - quantity note
  - last updated
- Button: Lägg till vara
- Row action: Lägg till i inköpslistan

## Inköp tab
Purpose: normal shared shopping list.

Recommended layout:
- Add item field at top
- Active items grouped by category
- Completed items collapsed or lower down
- Swipe/row action for complete/delete

## Inställningar tab
Fields:
- Stugans namn
- Max antal sängplatser, default 10
- iCloud sync/help section
- About/privacy section

## UI copy language
Use Swedish in MVP. Keep labels short and family-friendly.
