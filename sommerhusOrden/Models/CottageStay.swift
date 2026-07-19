import Foundation

/// En familjs/grupps vistelse i stugan.
/// Nätter räknas hotellstil: ankomstdagen ingår, avresedagen ingår inte.
struct CottageStay: Identifiable, Codable, Equatable {
    var id: UUID
    var familyName: String
    var arrivalDate: Date
    var departureDate: Date
    var peopleCount: Int
    /// Sängplatser som behövs; om nil används peopleCount.
    var bedSpacesNeeded: Int?
    var note: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        familyName: String,
        arrivalDate: Date,
        departureDate: Date,
        peopleCount: Int,
        bedSpacesNeeded: Int? = nil,
        note: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.familyName = familyName
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
        self.peopleCount = peopleCount
        self.bedSpacesNeeded = bedSpacesNeeded
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Sängplatser vistelsen upptar.
    var bedSpaces: Int {
        bedSpacesNeeded ?? peopleCount
    }

    var isValid: Bool {
        !familyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && departureDate >= arrivalDate
            && peopleCount >= 1
            && (bedSpacesNeeded.map { $0 >= 1 } ?? true)
    }

    /// Om vistelsen upptar sängplatser en viss dag (ankomst inkluderad, avresa exkluderad).
    func occupies(_ date: Date, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        let arrival = calendar.startOfDay(for: arrivalDate)
        let departure = calendar.startOfDay(for: departureDate)
        return day >= arrival && day < departure
    }
}
