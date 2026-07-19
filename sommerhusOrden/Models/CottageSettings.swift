import Foundation

/// Delade inställningar för stugan.
struct CottageSettings: Identifiable, Codable, Equatable {
    static let defaultMaxBedSpaces = 10
    static let defaultCottageName = "Sommerhuset"

    var id: UUID
    var cottageName: String
    var maxBedSpaces: Int
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        cottageName: String = CottageSettings.defaultCottageName,
        maxBedSpaces: Int = CottageSettings.defaultMaxBedSpaces,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.cottageName = cottageName
        self.maxBedSpaces = maxBedSpaces
        self.updatedAt = updatedAt
    }
}
