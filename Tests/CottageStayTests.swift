import XCTest
@testable import sommerhusOrden

final class CottageStayTests: XCTestCase {
    private let calendar = Calendar.current

    private func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: .now))!
    }

    private func makeStay(
        familyName: String = "Familjen Test",
        arrival: Int = 0,
        departure: Int = 3,
        peopleCount: Int = 2,
        bedSpacesNeeded: Int? = nil
    ) -> CottageStay {
        CottageStay(
            familyName: familyName,
            arrivalDate: day(arrival),
            departureDate: day(departure),
            peopleCount: peopleCount,
            bedSpacesNeeded: bedSpacesNeeded
        )
    }

    func testBedSpacesDefaultsToPeopleCount() {
        XCTAssertEqual(makeStay(peopleCount: 4).bedSpaces, 4)
    }

    func testBedSpacesUsesExplicitValueWhenSet() {
        XCTAssertEqual(makeStay(peopleCount: 4, bedSpacesNeeded: 5).bedSpaces, 5)
    }

    func testOccupiesIncludesArrivalDayExcludesDepartureDay() {
        let stay = makeStay(arrival: 0, departure: 3)
        XCTAssertTrue(stay.occupies(day(0)))
        XCTAssertTrue(stay.occupies(day(2)))
        XCTAssertFalse(stay.occupies(day(3)))
        XCTAssertFalse(stay.occupies(day(-1)))
    }

    func testValidStay() {
        XCTAssertTrue(makeStay().isValid)
    }

    func testInvalidWhenFamilyNameIsBlank() {
        XCTAssertFalse(makeStay(familyName: "   ").isValid)
    }

    func testInvalidWhenDepartureBeforeArrival() {
        XCTAssertFalse(makeStay(arrival: 3, departure: 0).isValid)
    }

    func testInvalidWhenPeopleCountIsZero() {
        XCTAssertFalse(makeStay(peopleCount: 0).isValid)
    }
}
