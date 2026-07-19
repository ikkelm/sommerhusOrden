import XCTest
@testable import sommerhusOrden

final class InventoryModelTests: XCTestCase {
    private func makeModel(inventory: [InventoryItem] = [], shopping: [ShoppingListItem] = []) -> AppModel {
        AppModel(repository: InMemoryCottageRepository(inventory: inventory, shoppingList: shopping))
    }

    // MARK: - Kategorifiltrering

    func testCategoryFiltering() {
        let items = [
            InventoryItem(name: "Mjölk", category: .fridge),
            InventoryItem(name: "Köttfärs", category: .freezer),
            InventoryItem(name: "Oregano", category: .pantry),
        ]
        let filtered = InventoryFilter.filter(items, category: .fridge)
        XCTAssertEqual(filtered.map(\.name), ["Mjölk"])
    }

    func testFilterCombinesSearchAndCategory() {
        let items = [
            InventoryItem(name: "Mjölk", category: .fridge),
            InventoryItem(name: "Lättmjölk", category: .fridge),
            InventoryItem(name: "Mjölkchoklad", category: .pantry),
        ]
        let filtered = InventoryFilter.filter(items, searchText: "mjölk", category: .fridge)
        XCTAssertEqual(filtered.map(\.name), ["Lättmjölk", "Mjölk"])
    }

    func testFilterSortsByName() {
        let items = [
            InventoryItem(name: "Örtsalt", category: .pantry),
            InventoryItem(name: "Ansjovis", category: .pantry),
        ]
        let filtered = InventoryFilter.filter(items)
        XCTAssertEqual(filtered.map(\.name), ["Ansjovis", "Örtsalt"])
    }

    // MARK: - Statusuppdatering

    func testStatusUpdateChangesLastUpdatedAt() throws {
        let old = Date(timeIntervalSinceNow: -3600)
        let item = InventoryItem(name: "Mjölk", category: .fridge, status: .available, lastUpdatedAt: old)
        let model = makeModel(inventory: [item])

        model.setInventoryStatus(id: item.id, status: .out)

        let updated = try XCTUnwrap(model.inventoryItems.first)
        XCTAssertEqual(updated.status, .out)
        XCTAssertGreaterThan(updated.lastUpdatedAt, old)
    }

    // MARK: - Till inköpslistan

    func testAddToShoppingListCreatesExpectedItem() {
        let item = InventoryItem(name: "Diskmedel", category: .household, status: .out)
        let model = makeModel(inventory: [item])

        let created = model.addToShoppingList(from: item)

        XCTAssertEqual(model.shoppingItems.count, 1)
        XCTAssertEqual(created.name, "Diskmedel")
        XCTAssertEqual(created.category, .household)
        XCTAssertFalse(created.isCompleted)
    }

    func testAddToShoppingListDoesNotDuplicateActiveItem() {
        let item = InventoryItem(name: "Mjölk", category: .fridge)
        let existing = ShoppingListItem(name: "mjölk")
        let model = makeModel(inventory: [item], shopping: [existing])

        let result = model.addToShoppingList(from: item)

        XCTAssertEqual(model.shoppingItems.count, 1)
        XCTAssertEqual(result.id, existing.id)
    }

    func testAddToShoppingListReactivatesCompletedItem() {
        let item = InventoryItem(name: "Kaffe", category: .pantry)
        let completed = ShoppingListItem(name: "Kaffe", isCompleted: true)
        let model = makeModel(inventory: [item], shopping: [completed])

        let result = model.addToShoppingList(from: item)

        XCTAssertEqual(model.shoppingItems.count, 1)
        XCTAssertEqual(result.id, completed.id)
        XCTAssertFalse(model.shoppingItems[0].isCompleted)
    }
}
