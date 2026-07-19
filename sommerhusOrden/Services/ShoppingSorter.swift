import Foundation

/// Sortering av inköpslistan, hållen fri från UI för testbarhet.
struct ShoppingSorter {
    /// Aktiva rader i tilläggsordning.
    static func active(_ items: [ShoppingListItem]) -> [ShoppingListItem] {
        items
            .filter { !$0.isCompleted }
            .sorted { $0.createdAt < $1.createdAt }
    }

    /// Avbockade rader, senast avbockad först.
    static func completed(_ items: [ShoppingListItem]) -> [ShoppingListItem] {
        items
            .filter(\.isCompleted)
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    /// Hela listan: aktiva före avbockade.
    static func ordered(_ items: [ShoppingListItem]) -> [ShoppingListItem] {
        active(items) + completed(items)
    }

    /// Aktiva rader grupperade per kategori, i kategoriordning; okategoriserade sist.
    static func activeGroupedByCategory(_ items: [ShoppingListItem]) -> [(category: InventoryCategory?, items: [ShoppingListItem])] {
        let activeItems = active(items)
        var groups: [(category: InventoryCategory?, items: [ShoppingListItem])] = []
        for category in InventoryCategory.allCases {
            let matching = activeItems.filter { $0.category == category }
            if !matching.isEmpty {
                groups.append((category, matching))
            }
        }
        let uncategorized = activeItems.filter { $0.category == nil }
        if !uncategorized.isEmpty {
            groups.append((nil, uncategorized))
        }
        return groups
    }
}
