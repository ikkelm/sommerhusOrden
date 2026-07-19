import XCTest
@testable import sommerhusOrden

final class InventorySearchTests: XCTestCase {
    func testMatchIsCaseInsensitive() {
        let item = InventoryItem(name: "Oregano", category: .pantry)
        XCTAssertTrue(item.matches(searchText: "oregano"))
        XCTAssertTrue(item.matches(searchText: "OREG"))
    }

    func testMatchOnSubstring() {
        let item = InventoryItem(name: "Lättmjölk", category: .fridge)
        XCTAssertTrue(item.matches(searchText: "mjölk"))
    }

    func testEmptySearchMatchesEverything() {
        let item = InventoryItem(name: "Kaffe", category: .pantry)
        XCTAssertTrue(item.matches(searchText: ""))
        XCTAssertTrue(item.matches(searchText: "   "))
    }

    func testNoMatch() {
        let item = InventoryItem(name: "Kaffe", category: .pantry)
        XCTAssertFalse(item.matches(searchText: "te"))
    }
}
