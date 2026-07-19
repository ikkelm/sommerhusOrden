import Foundation

enum InventoryCategory: String, Codable, CaseIterable, Identifiable {
    case fridge
    case freezer
    case pantry
    case household
    case other

    var id: String { rawValue }

    /// Svensk etikett för UI.
    var displayName: String {
        switch self {
        case .fridge: "Kyl"
        case .freezer: "Frys"
        case .pantry: "Skafferi"
        case .household: "Hushåll"
        case .other: "Annat"
        }
    }
}

enum InventoryStatus: String, Codable, CaseIterable, Identifiable {
    case available
    case low
    case out

    var id: String { rawValue }

    /// Svensk etikett för UI.
    var displayName: String {
        switch self {
        case .available: "Finns"
        case .low: "Lågt"
        case .out: "Slut"
        }
    }
}

/// En vara i stugans förråd (kyl, frys, skafferi, hushåll).
struct InventoryItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var category: InventoryCategory
    var status: InventoryStatus
    var quantityNote: String?
    var lastUpdatedAt: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: InventoryCategory,
        status: InventoryStatus = .available,
        quantityNote: String? = nil,
        lastUpdatedAt: Date = .now,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.status = status
        self.quantityNote = quantityNote
        self.lastUpdatedAt = lastUpdatedAt
        self.createdAt = createdAt
    }

    /// Lokaliserad, skiftlägesokänslig namnsökning.
    func matches(searchText: String) -> Bool {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        return name.localizedCaseInsensitiveContains(trimmed)
    }
}
