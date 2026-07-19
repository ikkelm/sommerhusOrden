import SwiftUI

/// Formulär för att redigera en rad i inköpslistan.
struct ShoppingItemFormView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    let item: ShoppingListItem

    @State private var name: String
    @State private var quantityNote: String
    @State private var category: InventoryCategory?

    init(item: ShoppingListItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _quantityNote = State(initialValue: item.quantityNote ?? "")
        _category = State(initialValue: item.category)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vara") {
                    TextField("Namn", text: $name)
                    TextField("Mängd/anteckning, t.ex. 2 liter", text: $quantityNote)
                }
                Section("Kategori") {
                    Picker("Kategori", selection: $category) {
                        Text("Ingen kategori").tag(InventoryCategory?.none)
                        ForEach(InventoryCategory.allCases) { category in
                            Text(category.displayName).tag(InventoryCategory?.some(category))
                        }
                    }
                }
            }
            .navigationTitle("Redigera vara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Spara") { save() }
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
    }

    private func save() {
        var updated = item
        let trimmedNote = quantityNote.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.name = trimmedName
        updated.quantityNote = trimmedNote.isEmpty ? nil : trimmedNote
        updated.category = category
        model.updateShoppingItem(updated)
        dismiss()
    }
}

#Preview {
    ShoppingItemFormView(item: SampleData.shoppingList[0])
        .environment(AppModel(repository: InMemoryCottageRepository()))
}
