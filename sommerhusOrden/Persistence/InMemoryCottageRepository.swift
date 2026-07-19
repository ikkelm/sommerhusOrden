import Foundation

/// Enkel lagring i minnet — platshållare tills lokal persistens
/// och CloudKit-synk införs i senare faser.
final class InMemoryCottageRepository: CottageRepository {
    private var settings: CottageSettings
    private var stays: [CottageStay]
    private var inventory: [InventoryItem]
    private var shoppingList: [ShoppingListItem]

    init(
        settings: CottageSettings = CottageSettings(),
        stays: [CottageStay] = [],
        inventory: [InventoryItem] = [],
        shoppingList: [ShoppingListItem] = []
    ) {
        self.settings = settings
        self.stays = stays
        self.inventory = inventory
        self.shoppingList = shoppingList
    }

    func loadSettings() -> CottageSettings { settings }
    func saveSettings(_ settings: CottageSettings) { self.settings = settings }

    func loadStays() -> [CottageStay] { stays }
    func saveStays(_ stays: [CottageStay]) { self.stays = stays }

    func loadInventory() -> [InventoryItem] { inventory }
    func saveInventory(_ items: [InventoryItem]) { inventory = items }

    func loadShoppingList() -> [ShoppingListItem] { shoppingList }
    func saveShoppingList(_ items: [ShoppingListItem]) { shoppingList = items }
}
