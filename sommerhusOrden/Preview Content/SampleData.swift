import Foundation

/// Exempeldata endast för SwiftUI-previews.
/// Ligger i Preview Content och följer inte med i release-byggen.
enum SampleData {
    static var stays: [CottageStay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return [
            CottageStay(
                familyName: "Familjen Wulff",
                arrivalDate: calendar.date(byAdding: .day, value: 3, to: today)!,
                departureDate: calendar.date(byAdding: .day, value: 10, to: today)!,
                peopleCount: 4,
                note: "Tar med båten"
            ),
            CottageStay(
                familyName: "Mormor och morfar",
                arrivalDate: calendar.date(byAdding: .day, value: 8, to: today)!,
                departureDate: calendar.date(byAdding: .day, value: 12, to: today)!,
                peopleCount: 2
            ),
        ]
    }

    static var inventory: [InventoryItem] {
        [
            InventoryItem(name: "Mjölk", category: .fridge, status: .low, quantityNote: "1 liter"),
            InventoryItem(name: "Oregano", category: .pantry, status: .available),
            InventoryItem(name: "Köttfärs", category: .freezer, status: .available, quantityNote: "2 paket"),
            InventoryItem(name: "Diskmedel", category: .household, status: .out),
        ]
    }

    static var shoppingList: [ShoppingListItem] {
        [
            ShoppingListItem(name: "Mjölk", quantityNote: "2 liter", category: .fridge),
            ShoppingListItem(name: "Diskmedel", category: .household),
            ShoppingListItem(name: "Kaffe", category: .pantry, isCompleted: true),
        ]
    }
}
