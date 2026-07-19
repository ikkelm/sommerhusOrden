import SwiftUI

/// Delad inköpslista: snabb tilläggning, avbockning och redigering.
struct InkopView: View {
    @Environment(AppModel.self) private var model

    @State private var newItemName = ""
    @State private var itemBeingEdited: ShoppingListItem?
    @State private var showingClearCompletedConfirmation = false
    @FocusState private var addFieldFocused: Bool

    private var activeGroups: [(category: InventoryCategory?, items: [ShoppingListItem])] {
        ShoppingSorter.activeGroupedByCategory(model.shoppingItems)
    }

    private var completedItems: [ShoppingListItem] {
        ShoppingSorter.completed(model.shoppingItems)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    addField
                }
                if model.shoppingItems.isEmpty {
                    EmptyStateView(
                        systemImage: "cart",
                        title: "Inköpslistan är tom",
                        message: "Skriv en vara ovan så hamnar den på familjens gemensamma lista. Bocka av medan du handlar."
                    )
                    .listRowBackground(Color.clear)
                }
                ForEach(activeGroups, id: \.category) { group in
                    Section(group.category?.displayName ?? (activeGroups.count > 1 ? "Övrigt att handla" : "Att handla")) {
                        ForEach(group.items) { item in
                            row(for: item)
                        }
                    }
                }
                if !completedItems.isEmpty {
                    completedSection
                }
            }
            .navigationTitle("Inköp")
            .sheet(item: $itemBeingEdited) { item in
                ShoppingItemFormView(item: item)
            }
            .confirmationDialog(
                "Rensa avbockade varor?",
                isPresented: $showingClearCompletedConfirmation,
                titleVisibility: .visible
            ) {
                Button("Rensa \(completedItems.count) avbockade", role: .destructive) {
                    model.clearCompletedShoppingItems()
                }
                Button("Avbryt", role: .cancel) {}
            }
        }
    }

    // MARK: - Delvyer

    private var addField: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            TextField("Lägg till vara …", text: $newItemName)
                .focused($addFieldFocused)
                .submitLabel(.done)
                .onSubmit(addItem)
        }
    }

    private var completedSection: some View {
        Section {
            ForEach(completedItems) { item in
                row(for: item)
            }
        } header: {
            HStack {
                Text("Klart (\(completedItems.count))")
                Spacer()
                Button("Rensa") {
                    showingClearCompletedConfirmation = true
                }
                .font(.footnote)
            }
        }
    }

    private func row(for item: ShoppingListItem) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation {
                    model.toggleShoppingItem(id: item.id)
                }
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isCompleted ? "Bocka av \(item.name) som ej klar" : "Bocka av \(item.name)")

            Button {
                itemBeingEdited = item
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .strikethrough(item.isCompleted)
                        .foregroundStyle(item.isCompleted ? .secondary : .primary)
                    if let note = item.quantityNote, !note.isEmpty {
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint("Tryck för att redigera")
        }
        .swipeActions(edge: .trailing) {
            Button("Ta bort", systemImage: "trash", role: .destructive) {
                withAnimation {
                    model.deleteShoppingItem(id: item.id)
                }
            }
            Button("Redigera", systemImage: "pencil") {
                itemBeingEdited = item
            }
            .tint(.blue)
        }
    }

    private func addItem() {
        guard model.addShoppingItem(name: newItemName) != nil else { return }
        newItemName = ""
        addFieldFocused = true
    }
}

#Preview("Tom") {
    InkopView()
        .environment(AppModel(repository: InMemoryCottageRepository()))
}

#Preview("Med varor") {
    InkopView()
        .environment(AppModel(repository: InMemoryCottageRepository(shoppingList: SampleData.shoppingList)))
}
