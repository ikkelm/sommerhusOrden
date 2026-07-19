import Foundation

/// Sök- och kategorifiltrering för förrådet, hållen fri från UI för testbarhet.
struct InventoryFilter {
    /// Filtrerar på valfri kategori och söktext, sorterat på namn.
    static func filter(
        _ items: [InventoryItem],
        searchText: String = "",
        category: InventoryCategory? = nil
    ) -> [InventoryItem] {
        items
            .filter { category == nil || $0.category == category }
            .filter { $0.matches(searchText: searchText) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
