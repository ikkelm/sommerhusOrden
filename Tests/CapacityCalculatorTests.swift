import XCTest
@testable import sommerhusOrden

final class CapacityCalculatorTests: XCTestCase {
    private let calendar = Calendar.current
    private let calculator = CapacityCalculator()

    private func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: .now))!
    }

    private func makeStay(arrival: Int, departure: Int, people: Int) -> CottageStay {
        CottageStay(
            familyName: "Familjen Test",
            arrivalDate: day(arrival),
            departureDate: day(departure),
            peopleCount: people
        )
    }

    func testBedSpacesUsedSumsOverlappingStays() {
        let stays = [
            makeStay(arrival: 0, departure: 5, people: 4),
            makeStay(arrival: 2, departure: 6, people: 3),
        ]
        XCTAssertEqual(calculator.bedSpacesUsed(in: stays, on: day(1)), 4)
        XCTAssertEqual(calculator.bedSpacesUsed(in: stays, on: day(3)), 7)
        XCTAssertEqual(calculator.bedSpacesUsed(in: stays, on: day(5)), 3)
        XCTAssertEqual(calculator.bedSpacesUsed(in: stays, on: day(6)), 0)
    }

    func testIsOverCapacity() {
        let stays = [
            makeStay(arrival: 0, departure: 5, people: 6),
            makeStay(arrival: 0, departure: 5, people: 5),
        ]
        XCTAssertTrue(calculator.isOverCapacity(in: stays, on: day(1), maxBedSpaces: 10))
        XCTAssertFalse(calculator.isOverCapacity(in: stays, on: day(1), maxBedSpaces: 11))
    }

    func testNextStayReturnsOngoingOrUpcoming() {
        let past = makeStay(arrival: -10, departure: -5, people: 2)
        let ongoing = makeStay(arrival: -1, departure: 2, people: 3)
        let future = makeStay(arrival: 5, departure: 8, people: 4)

        XCTAssertEqual(calculator.nextStay(in: [past, future, ongoing])?.id, ongoing.id)
        XCTAssertEqual(calculator.nextStay(in: [past, future])?.id, future.id)
        XCTAssertNil(calculator.nextStay(in: [past]))
    }
}
