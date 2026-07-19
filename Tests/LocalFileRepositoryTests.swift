import XCTest
@testable import sommerhusOrden

final class LocalFileRepositoryTests: XCTestCase {
    private var fileURL: URL!

    override func setUp() {
        super.setUp()
        fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("sommerhusOrden-tests-\(UUID().uuidString).json")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: fileURL)
        super.tearDown()
    }

    func testStartsWithDefaults() {
        let repository = LocalFileCottageRepository(fileURL: fileURL)
        XCTAssertEqual(repository.loadSettings().maxBedSpaces, 10)
        XCTAssertEqual(repository.loadSettings().cottageName, "Sommerhuset")
        XCTAssertTrue(repository.loadStays().isEmpty)
        XCTAssertTrue(repository.loadInventory().isEmpty)
        XCTAssertTrue(repository.loadShoppingList().isEmpty)
    }

    func testDataSurvivesReload() {
        let stay = CottageStay(
            familyName: "Familjen Test",
            arrivalDate: .now,
            departureDate: Date(timeIntervalSinceNow: 86_400 * 3),
            peopleCount: 4
        )
        let inventory = InventoryItem(name: "Kaffe", category: .pantry, status: .low)
        let shopping = ShoppingListItem(name: "Mjölk", category: .fridge)
        var settings = CottageSettings()
        settings.cottageName = "Lillstugan"
        settings.maxBedSpaces = 8

        let first = LocalFileCottageRepository(fileURL: fileURL)
        first.saveStays([stay])
        first.saveInventory([inventory])
        first.saveShoppingList([shopping])
        first.saveSettings(settings)

        let second = LocalFileCottageRepository(fileURL: fileURL)
        XCTAssertEqual(second.loadStays(), [stay])
        XCTAssertEqual(second.loadInventory(), [inventory])
        XCTAssertEqual(second.loadShoppingList(), [shopping])
        XCTAssertEqual(second.loadSettings().cottageName, "Lillstugan")
        XCTAssertEqual(second.loadSettings().maxBedSpaces, 8)
    }

    func testCorruptFileFallsBackToDefaults() throws {
        try Data("inte json".utf8).write(to: fileURL)
        let repository = LocalFileCottageRepository(fileURL: fileURL)
        XCTAssertEqual(repository.loadSettings().maxBedSpaces, 10)
        XCTAssertTrue(repository.loadStays().isEmpty)
    }
}
