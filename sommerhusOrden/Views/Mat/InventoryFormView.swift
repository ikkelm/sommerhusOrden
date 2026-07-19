import SwiftUI

/// Formulär för att lägga till eller redigera en förrådsvara.
struct InventoryFormView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    /// Vara som redigeras; nil betyder ny vara.
    let existingItem: InventoryItem?

    @State private var name: String
    @State private var category: InventoryCategory
    @State private var status: InventoryStatus
    @State private var quantityNote: String

    init(existingItem: InventoryItem? = nil) {
        self.existingItem = existingItem
        _name = State(initialValue: existingItem?.name ?? "")
        _category = State(initialValue: existingItem?.category ?? .pantry)
        _status = State(initialValue: existingItem?.status ?? .available)
        _quantityNote = State(initialValue: existingItem?.quantityNote ?? "")
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vara") {
                    TextField("T.ex. Oregano", text: $name)
                    Picker("Kategori", selection: $category) {
                        ForEach(InventoryCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(InventoryStatus.allCases) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Mängd/anteckning") {
                    TextField("T.ex. 2 paket", text: $quantityNote)
                }
            }
            .navigationTitle(existingItem == nil ? "Ny vara" : "Redigera vara")
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
        let trimmedNote = quantityNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if var item = existingItem {
            item.name = trimmedName
            item.category = category
            item.status = status
            item.quantityNote = trimmedNote.isEmpty ? nil : trimmedNote
            model.updateInventoryItem(item)
        } else {
            model.addInventoryItem(
                InventoryItem(
                    name: trimmedName,
                    category: category,
                    status: status,
                    quantityNote: trimmedNote.isEmpty ? nil : trimmedNote
                )
            )
        }
        dismiss()
    }
}

#Preview("Ny vara") {
    InventoryFormView()
        .environment(AppModel(repository: InMemoryCottageRepository()))
}

#Preview("Redigera") {
    InventoryFormView(existingItem: SampleData.inventory.first)
        .environment(AppModel(repository: InMemoryCottageRepository()))
}
