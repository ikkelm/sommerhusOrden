import Foundation

/// Lokal JSON-lagring i Application Support.
/// Fungerar helt offline; CloudKit-synk läggs ovanpå via CloudKitSyncService.
final class LocalFileCottageRepository: CottageRepository {
    private struct StoreData: Codable {
        var settings: CottageSettings = CottageSettings()
        var stays: [CottageStay] = []
        var inventory: [InventoryItem] = []
        var shoppingList: [ShoppingListItem] = []
    }

    private let fileURL: URL
    private var data: StoreData

    /// - Parameter fileURL: Överstyr lagringsplats, används i tester.
    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL()
        self.data = Self.load(from: self.fileURL) ?? StoreData()
    }

    static func defaultFileURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = base.appendingPathComponent("sommerhusOrden", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("store.json")
    }

    private static func load(from url: URL) -> StoreData? {
        guard let raw = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(StoreData.self, from: raw)
    }

    private func persist() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            let raw = try encoder.encode(data)
            try raw.write(to: fileURL, options: .atomic)
        } catch {
            // Lokal lagring är bästa möjliga; nästa lyckade skrivning tar igen det.
            // Ingen användardata går förlorad i minnet.
            print("sommerhusOrden: kunde inte spara lokalt: \(error)")
        }
    }

    func loadSettings() -> CottageSettings { data.settings }
    func saveSettings(_ settings: CottageSettings) {
        data.settings = settings
        persist()
    }

    func loadStays() -> [CottageStay] { data.stays }
    func saveStays(_ stays: [CottageStay]) {
        data.stays = stays
        persist()
    }

    func loadInventory() -> [InventoryItem] { data.inventory }
    func saveInventory(_ items: [InventoryItem]) {
        data.inventory = items
        persist()
    }

    func loadShoppingList() -> [ShoppingListItem] { data.shoppingList }
    func saveShoppingList(_ items: [ShoppingListItem]) {
        data.shoppingList = items
        persist()
    }
}
