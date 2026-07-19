import XCTest
@testable import sommerhusOrden

final class WeekPlannerTests: XCTestCase {
    private let planner = WeekPlanner()

    private var calendar: Calendar { planner.calendar }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func makeStay(
        familyName: String = "Familjen Test",
        arrival: Date,
        departure: Date,
        people: Int = 2,
        bedSpaces: Int? = nil
    ) -> CottageStay {
        CottageStay(
            familyName: familyName,
            arrivalDate: arrival,
            departureDate: departure,
            peopleCount: people,
            bedSpacesNeeded: bedSpaces
        )
    }

    func testSingleStayWithinOneWeek() {
        // Måndag till fredag samma vecka.
        let stay = makeStay(arrival: date(2026, 7, 20), departure: date(2026, 7, 24), people: 4)
        let weeks = planner.weekOverviews(for: [stay])

        XCTAssertEqual(weeks.count, 1)
        XCTAssertEqual(weeks.first?.weekOfYear, 30)
        XCTAssertEqual(weeks.first?.peakBedSpaces, 4)
    }

    func testStaySpanningTwoWeeks() {
        // Fredag v.30 till onsdag v.31.
        let stay = makeStay(arrival: date(2026, 7, 24), departure: date(2026, 7, 29), people: 3)
        let weeks = planner.weekOverviews(for: [stay])

        XCTAssertEqual(weeks.count, 2)
        XCTAssertEqual(weeks.map(\.weekOfYear), [30, 31])
        XCTAssertTrue(weeks.allSatisfy { $0.peakBedSpaces == 3 })
    }

    func testWeekGroupingAcrossYearBoundary() {
        // ISO-vecka 53 2026 löper mån 28 dec – sön 3 jan 2027.
        // Vistelse 30 dec – 6 jan har nätter i både v.53 (2026) och v.1 (2027).
        let stay = makeStay(arrival: date(2026, 12, 30), departure: date(2027, 1, 6), people: 2)
        let weeks = planner.weekOverviews(for: [stay])

        XCTAssertEqual(weeks.count, 2)
        XCTAssertEqual(weeks[0].weekOfYear, 53)
        XCTAssertEqual(weeks[0].yearForWeekOfYear, 2026)
        XCTAssertEqual(weeks[1].weekOfYear, 1)
        XCTAssertEqual(weeks[1].yearForWeekOfYear, 2027)
        XCTAssertEqual(weeks[1].id, "2027-W01")
    }

    func testOverlappingStaysSummedPerWeek() {
        let a = makeStay(familyName: "A", arrival: date(2026, 7, 20), departure: date(2026, 7, 25), people: 5)
        let b = makeStay(familyName: "B", arrival: date(2026, 7, 22), departure: date(2026, 7, 26), people: 4)
        let weeks = planner.weekOverviews(for: [a, b])

        XCTAssertEqual(weeks.count, 1)
        XCTAssertEqual(weeks.first?.peakBedSpaces, 9)
        XCTAssertEqual(weeks.first?.stays.count, 2)
    }

    func testOverCapacityDetection() {
        let a = makeStay(familyName: "A", arrival: date(2026, 7, 20), departure: date(2026, 7, 25), people: 6)
        let b = makeStay(familyName: "B", arrival: date(2026, 7, 22), departure: date(2026, 7, 26), people: 5)
        let weeks = planner.weekOverviews(for: [a, b])

        XCTAssertTrue(weeks[0].isOverCapacity(maxBedSpaces: 10))
        XCTAssertFalse(weeks[0].isOverCapacity(maxBedSpaces: 11))
    }

    func testDepartureDayDoesNotCountTowardsFollowingWeek() {
        // Avresa måndag: sista natten är söndag, så nästa vecka ska inte skapas.
        let stay = makeStay(arrival: date(2026, 7, 24), departure: date(2026, 7, 27), people: 2)
        let weeks = planner.weekOverviews(for: [stay])

        XCTAssertEqual(weeks.count, 1)
        XCTAssertEqual(weeks.first?.weekOfYear, 30)
    }

    func testInvalidStaysAreIgnored() {
        let invalid = makeStay(familyName: " ", arrival: date(2026, 7, 20), departure: date(2026, 7, 24))
        XCTAssertTrue(planner.weekOverviews(for: [invalid]).isEmpty)
    }
}
