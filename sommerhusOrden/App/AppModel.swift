import Foundation
import Observation

/// Appens delade tillstånd. Läser och skriver via repository-lagret
/// så att persistensen kan bytas ut i senare faser.
@Observable
final class AppModel {
    /// Sätts av appen efter start; nil i tester/previews.
    @ObservationIgnored weak var syncService: CloudKitSyncService?

    /// Skydd mot att fjärrändringar studsar tillbaka ut i synk-kön.
    @ObservationIgnored private var isApplyingRemoteChange = false

    var settings: CottageSettings {
        didSet {
            guard settings != oldValue else { return }
            if !isApplyingRemoteChange {
                settings.updatedAt = .now
                syncService?.queueSaveSettings()
            }
            repository.saveSettings(settings)
        }
    }
    var stays: [CottageStay] {
        didSet { repository.saveStays(stays) }
    }
    var inventoryItems: [InventoryItem] {
        didSet { repository.saveInventory(inventoryItems) }
    }
    var shoppingItems: [ShoppingListItem] {
        didSet { repository.saveShoppingList(shoppingItems) }
    }

    private let repository: CottageRepository

    init(repository: CottageRepository) {
        self.repository = repository
        self.settings = repository.loadSettings()
        self.stays = repository.loadStays()
        self.inventoryItems = repository.loadInventory()
        self.shoppingItems = repository.loadShoppingList()
    }

    /// Tar emot inställningar från synk utan att stämpla om updatedAt.
    func applyRemoteSettings(_ remote: CottageSettings) {
        isApplyingRemoteChange = true
        settings = remote
        isApplyingRemoteChange = false
    }

    // MARK: - Vistelser

    func addStay(_ stay: CottageStay) {
        stays.append(stay)
        syncService?.queueSaveStay(stay.id)
    }

    func updateStay(_ stay: CottageStay) {
        guard let index = stays.firstIndex(where: { $0.id == stay.id }) else { return }
        var updated = stay
        updated.updatedAt = .now
        stays[index] = updated
        syncService?.queueSaveStay(stay.id)
    }

    func deleteStay(id: UUID) {
        stays.removeAll { $0.id == id }
        syncService?.queueDeleteStay(id)
    }

    // MARK: - Förråd

    func addInventoryItem(_ item: InventoryItem) {
        inventoryItems.append(item)
        syncService?.queueSaveInventory(item.id)
    }

    func updateInventoryItem(_ item: InventoryItem) {
        guard let index = inventoryItems.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = item
        updated.lastUpdatedAt = .now
        inventoryItems[index] = updated
        syncService?.queueSaveInventory(item.id)
    }

    func setInventoryStatus(id: UUID, status: InventoryStatus) {
        guard let index = inventoryItems.firstIndex(where: { $0.id == id }) else { return }
        inventoryItems[index].status = status
        inventoryItems[index].lastUpdatedAt = .now
        syncService?.queueSaveInventory(id)
    }

    func deleteInventoryItem(id: UUID) {
        inventoryItems.removeAll { $0.id == id }
        syncService?.queueDeleteInventory(id)
    }

    /// Lägger till en förrådsvara i inköpslistan.
    /// Finns varan redan som aktiv rad återanvänds den; en avbockad rad bockas av igen.
    @discardableResult
    func addToShoppingList(from item: InventoryItem) -> ShoppingListItem {
        if let index = shoppingItems.firstIndex(where: {
            $0.name.localizedCaseInsensitiveCompare(item.name) == .orderedSame
        }) {
            if shoppingItems[index].isCompleted {
                shoppingItems[index].isCompleted = false
                shoppingItems[index].updatedAt = .now
                syncService?.queueSaveShopping(shoppingItems[index].id)
            }
            return shoppingItems[index]
        }
        let newItem = ShoppingListItem(name: item.name, category: item.category)
        shoppingItems.append(newItem)
        syncService?.queueSaveShopping(newItem.id)
        return newItem
    }

    // MARK: - Inköpslista

    /// Snabb tilläggning; ignorerar tomma namn.
    @discardableResult
    func addShoppingItem(name: String, quantityNote: String? = nil, category: InventoryCategory? = nil) -> ShoppingListItem? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let item = ShoppingListItem(name: trimmed, quantityNote: quantityNote, category: category)
        shoppingItems.append(item)
        syncService?.queueSaveShopping(item.id)
        return item
    }

    func updateShoppingItem(_ item: ShoppingListItem) {
        guard let index = shoppingItems.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = item
        updated.updatedAt = .now
        shoppingItems[index] = updated
        syncService?.queueSaveShopping(item.id)
    }

    /// Bockar av eller återaktiverar en rad.
    func toggleShoppingItem(id: UUID) {
        guard let index = shoppingItems.firstIndex(where: { $0.id == id }) else { return }
        shoppingItems[index].isCompleted.toggle()
        shoppingItems[index].updatedAt = .now
        syncService?.queueSaveShopping(id)
    }

    func deleteShoppingItem(id: UUID) {
        shoppingItems.removeAll { $0.id == id }
        syncService?.queueDeleteShopping(id)
    }

    func clearCompletedShoppingItems() {
        let completedIDs = shoppingItems.filter(\.isCompleted).map(\.id)
        shoppingItems.removeAll { $0.isCompleted }
        for id in completedIDs {
            syncService?.queueDeleteShopping(id)
        }
    }
}
