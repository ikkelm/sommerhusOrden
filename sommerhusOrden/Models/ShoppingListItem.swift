import Foundation

/// En rad i den delade inköpslistan.
struct ShoppingListItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var quantityNote: String?
    var category: InventoryCategory?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        quantityNote: String? = nil,
        category: InventoryCategory? = nil,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.quantityNote = quantityNote
        self.category = category
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
