import Foundation

/// Domänberäkningar för sängplatser och kapacitet.
struct CapacityCalculator {
    var calendar: Calendar = .current

    /// Totalt antal upptagna sängplatser en viss dag.
    func bedSpacesUsed(in stays: [CottageStay], on date: Date) -> Int {
        stays
            .filter { $0.occupies(date, calendar: calendar) }
            .reduce(0) { $0 + $1.bedSpaces }
    }

    /// Om bokade sängplatser överstiger max en viss dag.
    func isOverCapacity(in stays: [CottageStay], on date: Date, maxBedSpaces: Int) -> Bool {
        bedSpacesUsed(in: stays, on: date) > maxBedSpaces
    }

    /// Nästa kommande vistelse (pågående eller framtida), sorterad på ankomst.
    func nextStay(in stays: [CottageStay], from date: Date = .now) -> CottageStay? {
        let today = calendar.startOfDay(for: date)
        return stays
            .filter { calendar.startOfDay(for: $0.departureDate) > today }
            .min { $0.arrivalDate < $1.arrivalDate }
    }
}
