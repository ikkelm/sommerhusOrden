import XCTest
@testable import sommerhusOrden

final class ShoppingListTests: XCTestCase {
    private func makeModel(shopping: [ShoppingListItem] = []) -> AppModel {
        AppModel(repository: InMemoryCottageRepository(shoppingList: shopping))
    }

    // MARK: - Lägga till

    func testAddItem() throws {
        let model = makeModel()
        let added = model.addShoppingItem(name: "  Mjölk  ")

        XCTAssertEqual(model.shoppingItems.count, 1)
        XCTAssertEqual(try XCTUnwrap(added).name, "Mjölk")
        XCTAssertFalse(try XCTUnwrap(added).isCompleted)
    }

    func testAddItemRejectsBlankName() {
        let model = makeModel()
        XCTAssertNil(model.addShoppingItem(name: "   "))
        XCTAssertTrue(model.shoppingItems.isEmpty)
    }

    // MARK: - Sortering

    func testActiveItemsSortBeforeCompleted() {
        let completed = ShoppingListItem(name: "Kaffe", isCompleted: true, createdAt: Date(timeIntervalSinceNow: -300))
        let active = ShoppingListItem(name: "Mjölk", createdAt: Date(timeIntervalSinceNow: -100))
        let ordered = ShoppingSorter.ordered([completed, active])

        XCTAssertEqual(ordered.map(\.name), ["Mjölk", "Kaffe"])
    }

    func testActiveGroupedByCategoryPutsUncategorizedLast() {
        let fridge = ShoppingListItem(name: "Mjölk", category: .fridge)
        let none = ShoppingListItem(name: "Blommor")
        let pantry = ShoppingListItem(name: "Kaffe", category: .pantry)
        let groups = ShoppingSorter.activeGroupedByCategory([none, fridge, pantry])

        XCTAssertEqual(groups.map(\.category), [.fridge, .pantry, nil])
    }

    // MARK: - Avbocka

    func testToggleCompletesAndUncompletesItem() throws {
        let item = ShoppingListItem(name: "Mjölk")
        let model = makeModel(shopping: [item])

        model.toggleShoppingItem(id: item.id)
        XCTAssertTrue(try XCTUnwrap(model.shoppingItems.first).isCompleted)

        model.toggleShoppingItem(id: item.id)
        XCTAssertFalse(try XCTUnwrap(model.shoppingItems.first).isCompleted)
    }

    // MARK: - Ta bort

    func testDeleteItem() {
        let item = ShoppingListItem(name: "Mjölk")
        let keep = ShoppingListItem(name: "Kaffe")
        let model = makeModel(shopping: [item, keep])

        model.deleteShoppingItem(id: item.id)

        XCTAssertEqual(model.shoppingItems.map(\.name), ["Kaffe"])
    }

    func testClearCompletedRemovesOnlyCompleted() {
        let done = ShoppingListItem(name: "Kaffe", isCompleted: true)
        let active = ShoppingListItem(name: "Mjölk")
        let model = makeModel(shopping: [done, active])

        model.clearCompletedShoppingItems()

        XCTAssertEqual(model.shoppingItems.map(\.name), ["Mjölk"])
    }

    // MARK: - Redigera

    func testUpdateItemChangesFieldsAndTimestamp() throws {
        let item = ShoppingListItem(name: "Mjölk", updatedAt: Date(timeIntervalSinceNow: -3600))
        let model = makeModel(shopping: [item])

        var edited = item
        edited.name = "Lättmjölk"
        edited.quantityNote = "2 liter"
        edited.category = .fridge
        model.updateShoppingItem(edited)

        let stored = try XCTUnwrap(model.shoppingItems.first)
        XCTAssertEqual(stored.name, "Lättmjölk")
        XCTAssertEqual(stored.quantityNote, "2 liter")
        XCTAssertEqual(stored.category, .fridge)
        XCTAssertGreaterThan(stored.updatedAt, item.updatedAt)
    }
}
