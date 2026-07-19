import Foundation

/// Abstraktion över lagring så att persistens (och senare CloudKit-synk)
/// kan bytas ut utan att UI eller domänlogik skrivs om.
protocol CottageRepository {
    func loadSettings() -> CottageSettings
    func saveSettings(_ settings: CottageSettings)

    func loadStays() -> [CottageStay]
    func saveStays(_ stays: [CottageStay])

    func loadInventory() -> [InventoryItem]
    func saveInventory(_ items: [InventoryItem])

    func loadShoppingList() -> [ShoppingListItem]
    func saveShoppingList(_ items: [ShoppingListItem])
}
