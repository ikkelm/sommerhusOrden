import SwiftUI

/// Översikt: vem är i stugan, vecka för vecka, och räcker sängplatserna?
struct StuganView: View {
    @Environment(AppModel.self) private var model

    @State private var showingAddStay = false
    @State private var stayBeingEdited: CottageStay?
    @State private var stayPendingDeletion: CottageStay?

    private let planner = WeekPlanner()
    private let capacity = CapacityCalculator()

    private var weekOverviews: [WeekOverview] {
        planner.weekOverviews(for: model.stays)
    }

    var body: some View {
        NavigationStack {
            Group {
                if model.stays.isEmpty {
                    emptyState
                } else {
                    weekList
                }
            }
            .navigationTitle("Stugan")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddStay = true
                    } label: {
                        Label("Lägg till vistelse", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddStay) {
                StayFormView()
            }
            .sheet(item: $stayBeingEdited) { stay in
                StayFormView(existingStay: stay)
            }
            .confirmationDialog(
                "Ta bort vistelsen?",
                isPresented: Binding(
                    get: { stayPendingDeletion != nil },
                    set: { if !$0 { stayPendingDeletion = nil } }
                ),
                titleVisibility: .visible,
                presenting: stayPendingDeletion
            ) { stay in
                Button("Ta bort \(stay.familyName)s vistelse", role: .destructive) {
                    model.deleteStay(id: stay.id)
                    stayPendingDeletion = nil
                }
                Button("Avbryt", role: .cancel) {
                    stayPendingDeletion = nil
                }
            } message: { stay in
                Text("\(stay.familyName), \(dateRangeText(stay.arrivalDate, stay.departureDate)). Detta går inte att ångra.")
            }
        }
    }

    // MARK: - Delvyer

    private var emptyState: some View {
        VStack(spacing: 16) {
            summaryCard
            EmptyStateView(
                systemImage: "house",
                title: "Inga vistelser planerade",
                message: "Lägg till en vistelse med plusknappen så ser hela familjen vem som är i stugan och när."
            )
        }
        .padding()
    }

    private var weekList: some View {
        List {
            Section {
                summaryCard
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            ForEach(weekOverviews) { week in
                Section {
                    ForEach(week.stays) { stay in
                        stayRow(stay)
                    }
                } header: {
                    weekHeader(week)
                } footer: {
                    weekFooter(week)
                }
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.settings.cottageName)
                .font(.title2.bold())
            if let next = capacity.nextStay(in: model.stays) {
                Text("Nästa vistelse: \(next.familyName), \(next.arrivalDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
            } else {
                Text("Ingen kommande vistelse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("Max sängplatser: \(model.settings.maxBedSpaces)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }

    private func weekHeader(_ week: WeekOverview) -> some View {
        HStack {
            Text("v. \(week.weekOfYear) · \(weekRangeText(week))")
            Spacer()
            if week.isOverCapacity(maxBedSpaces: model.settings.maxBedSpaces) {
                Label("Överbokat", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.footnote.bold())
            }
        }
    }

    private func weekFooter(_ week: WeekOverview) -> some View {
        let max = model.settings.maxBedSpaces
        let over = week.isOverCapacity(maxBedSpaces: max)
        return Text("Som mest \(week.peakBedSpaces) av \(max) sängplatser upptagna.")
            .foregroundStyle(over ? .red : .secondary)
    }

    private func stayRow(_ stay: CottageStay) -> some View {
        Button {
            stayBeingEdited = stay
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(stay.familyName)
                    .font(.headline)
                Text(dateRangeText(stay.arrivalDate, stay.departureDate))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption)
                    Text(peopleText(stay))
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)
                if let note = stay.note, !note.isEmpty {
                    Text(note)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button("Ta bort", systemImage: "trash", role: .destructive) {
                stayPendingDeletion = stay
            }
            Button("Redigera", systemImage: "pencil") {
                stayBeingEdited = stay
            }
            .tint(.blue)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Tryck för att redigera")
    }

    // MARK: - Formatering

    private func peopleText(_ stay: CottageStay) -> String {
        if stay.bedSpaces == stay.peopleCount {
            return "\(stay.peopleCount) personer"
        }
        return "\(stay.peopleCount) personer, \(stay.bedSpaces) sängplatser"
    }

    private func dateRangeText(_ from: Date, _ to: Date) -> String {
        "\(from.formatted(date: .abbreviated, time: .omitted)) – \(to.formatted(date: .abbreviated, time: .omitted))"
    }

    private func weekRangeText(_ week: WeekOverview) -> String {
        let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: week.interval.end) ?? week.interval.end
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sv_SE")
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: week.interval.start)) – \(formatter.string(from: lastDay))"
    }
}

#Preview("Tom") {
    StuganView()
        .environment(AppModel(repository: InMemoryCottageRepository()))
}

#Preview("Med vistelser") {
    StuganView()
        .environment(AppModel(repository: InMemoryCottageRepository(stays: SampleData.stays)))
}
