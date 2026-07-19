import SwiftUI

/// Förråd: svarar snabbt på "har vi X?" och låter familjen uppdatera status.
struct MatView: View {
    @Environment(AppModel.self) private var model

    @State private var searchText = ""
    @State private var selectedCategory: InventoryCategory?
    @State private var showingAddItem = false
    @State private var itemBeingEdited: InventoryItem?
    @State private var itemPendingDeletion: InventoryItem?
    @State private var addedToListName: String?

    private var filteredItems: [InventoryItem] {
        InventoryFilter.filter(model.inventoryItems, searchText: searchText, category: selectedCategory)
    }

    var body: some View {
        NavigationStack {
            Group {
                if model.inventoryItems.isEmpty {
                    EmptyStateView(
                        systemImage: "refrigerator",
                        title: "Inga varor ännu",
                        message: "Lägg till det som finns i kyl, frys, skafferi och hushåll — så slipper familjen gissa och handla dubbelt."
                    )
                } else {
                    itemList
                }
            }
            .navigationTitle("Mat")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Lägg till vara", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                InventoryFormView()
            }
            .sheet(item: $itemBeingEdited) { item in
                InventoryFormView(existingItem: item)
            }
            .confirmationDialog(
                "Ta bort varan?",
                isPresented: Binding(
                    get: { itemPendingDeletion != nil },
                    set: { if !$0 { itemPendingDeletion = nil } }
                ),
                titleVisibility: .visible,
                presenting: itemPendingDeletion
            ) { item in
                Button("Ta bort \u{201D}\(item.name)\u{201D}", role: .destructive) {
                    model.deleteInventoryItem(id: item.id)
                    itemPendingDeletion = nil
                }
                Button("Avbryt", role: .cancel) {
                    itemPendingDeletion = nil
                }
            }
        }
    }

    // MARK: - Delvyer

    private var itemList: some View {
        List {
            Section {
                categoryChips
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
            }
            if filteredItems.isEmpty {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "Inga träffar",
                    message: searchText.isEmpty
                        ? "Inga varor i den valda kategorin."
                        : "Ingen vara matchar \u{201D}\(searchText)\u{201D}."
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredItems) { item in
                    itemRow(item)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Sök vara, t.ex. oregano")
        .overlay(alignment: .bottom) {
            if let name = addedToListName {
                addedBanner(name)
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "Alla", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(InventoryCategory.allCases) { category in
                    chip(title: category.displayName, isSelected: selectedCategory == category) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func itemRow(_ item: InventoryItem) -> some View {
        Button {
            itemBeingEdited = item
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                    HStack(spacing: 6) {
                        Text(item.category.displayName)
                        if let note = item.quantityNote, !note.isEmpty {
                            Text("· \(note)")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    Text("Uppdaterad \(item.lastUpdatedAt.formatted(.relative(presentation: .named)))")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                statusBadge(item.status)
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button("Ta bort", systemImage: "trash", role: .destructive) {
                itemPendingDeletion = item
            }
            Button("Till inköp", systemImage: "cart.badge.plus") {
                addToShoppingList(item)
            }
            .tint(.green)
        }
        .contextMenu {
            statusMenu(for: item)
            Button("Lägg till i inköpslistan", systemImage: "cart.badge.plus") {
                addToShoppingList(item)
            }
            Button("Redigera", systemImage: "pencil") {
                itemBeingEdited = item
            }
            Button("Ta bort", systemImage: "trash", role: .destructive) {
                itemPendingDeletion = item
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Tryck för att redigera. Håll intryckt för fler val.")
    }

    @ViewBuilder
    private func statusMenu(for item: InventoryItem) -> some View {
        ForEach(InventoryStatus.allCases) { status in
            Button {
                model.setInventoryStatus(id: item.id, status: status)
            } label: {
                if item.status == status {
                    Label(status.displayName, systemImage: "checkmark")
                } else {
                    Text(status.displayName)
                }
            }
        }
    }

    private func statusBadge(_ status: InventoryStatus) -> some View {
        Text(status.displayName)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(status).opacity(0.15), in: Capsule())
            .foregroundStyle(statusColor(status))
            .accessibilityLabel("Status: \(status.displayName)")
    }

    private func statusColor(_ status: InventoryStatus) -> Color {
        switch status {
        case .available: .green
        case .low: .orange
        case .out: .red
        }
    }

    private func addedBanner(_ name: String) -> some View {
        Text("\u{201D}\(name)\u{201D} tillagd i inköpslistan")
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.thinMaterial, in: Capsule())
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func addToShoppingList(_ item: InventoryItem) {
        model.addToShoppingList(from: item)
        withAnimation {
            addedToListName = item.name
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                if addedToListName == item.name {
                    addedToListName = nil
                }
            }
        }
    }
}

#Preview("Tom") {
    MatView()
        .environment(AppModel(repository: InMemoryCottageRepository()))
}

#Preview("Med varor") {
    MatView()
        .environment(AppModel(repository: InMemoryCottageRepository(inventory: SampleData.inventory)))
}
