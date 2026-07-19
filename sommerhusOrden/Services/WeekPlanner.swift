import Foundation

/// En kalendervecka med de vistelser som berör den.
struct WeekOverview: Identifiable, Equatable {
    /// Stabilt id, t.ex. "2026-W30".
    let id: String
    let weekOfYear: Int
    /// Veckobaserat år (kan skilja sig från kalenderåret runt årsskiftet).
    let yearForWeekOfYear: Int
    /// Måndag 00:00 till nästa måndag 00:00.
    let interval: DateInterval
    let stays: [CottageStay]
    /// Högsta antal upptagna sängplatser någon natt under veckan.
    let peakBedSpaces: Int

    func isOverCapacity(maxBedSpaces: Int) -> Bool {
        peakBedSpaces > maxBedSpaces
    }
}

/// Grupperar vistelser per kalendervecka och räknar kapacitet.
/// Nätter räknas hotellstil: ankomstdagen ingår, avresedagen ingår inte.
struct WeekPlanner {
    /// ISO 8601: veckan börjar på måndag, veckonummer enligt svensk standard.
    var calendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar
    }()

    /// Veckoöversikter för alla veckor som berörs av minst en vistelse, i datumordning.
    func weekOverviews(for stays: [CottageStay]) -> [WeekOverview] {
        var weekStarts: Set<Date> = []
        for stay in stays where stay.isValid {
            var day = calendar.startOfDay(for: stay.arrivalDate)
            let departure = calendar.startOfDay(for: stay.departureDate)
            while day < departure {
                weekStarts.insert(startOfWeek(containing: day))
                guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                day = next
            }
        }

        return weekStarts.sorted().compactMap { weekStart in
            overview(forWeekStarting: weekStart, stays: stays)
        }
    }

    private func startOfWeek(containing date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    private func overview(forWeekStarting weekStart: Date, stays: [CottageStay]) -> WeekOverview? {
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return nil }
        let interval = DateInterval(start: weekStart, end: weekEnd)

        let staysInWeek = stays.filter { stay in
            let arrival = calendar.startOfDay(for: stay.arrivalDate)
            let departure = calendar.startOfDay(for: stay.departureDate)
            return arrival < weekEnd && departure > weekStart
        }
        guard !staysInWeek.isEmpty else { return nil }

        let capacity = CapacityCalculator(calendar: calendar)
        var peak = 0
        var day = weekStart
        while day < weekEnd {
            peak = max(peak, capacity.bedSpacesUsed(in: staysInWeek, on: day))
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }

        let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: weekStart)
        let week = components.weekOfYear ?? 0
        let year = components.yearForWeekOfYear ?? 0

        return WeekOverview(
            id: String(format: "%04d-W%02d", year, week),
            weekOfYear: week,
            yearForWeekOfYear: year,
            interval: interval,
            stays: staysInWeek.sorted { $0.arrivalDate < $1.arrivalDate },
            peakBedSpaces: peak
        )
    }
}
