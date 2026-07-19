import SwiftUI

/// Formulär för att lägga till eller redigera en vistelse.
struct StayFormView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    /// Vistelse som redigeras; nil betyder ny vistelse.
    let existingStay: CottageStay?

    @State private var familyName: String
    @State private var arrivalDate: Date
    @State private var departureDate: Date
    @State private var peopleCount: Int
    @State private var useSeparateBedSpaces: Bool
    @State private var bedSpacesNeeded: Int
    @State private var note: String

    init(existingStay: CottageStay? = nil) {
        self.existingStay = existingStay
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        _familyName = State(initialValue: existingStay?.familyName ?? "")
        _arrivalDate = State(initialValue: existingStay?.arrivalDate ?? today)
        _departureDate = State(
            initialValue: existingStay?.departureDate
                ?? calendar.date(byAdding: .day, value: 2, to: today) ?? today
        )
        _peopleCount = State(initialValue: existingStay?.peopleCount ?? 2)
        _useSeparateBedSpaces = State(initialValue: existingStay?.bedSpacesNeeded != nil)
        _bedSpacesNeeded = State(
            initialValue: existingStay?.bedSpacesNeeded ?? existingStay?.peopleCount ?? 2
        )
        _note = State(initialValue: existingStay?.note ?? "")
    }

    private var isEditing: Bool { existingStay != nil }

    private var trimmedName: String {
        familyName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValid: Bool {
        !trimmedName.isEmpty
            && departureDate > arrivalDate
            && peopleCount >= 1
            && (!useSeparateBedSpaces || bedSpacesNeeded >= 1)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Familj/grupp") {
                    TextField("T.ex. Familjen Wulff", text: $familyName)
                        .textInputAutocapitalization(.words)
                }

                Section {
                    DatePicker("Ankomst", selection: $arrivalDate, displayedComponents: .date)
                    DatePicker("Avresa", selection: $departureDate, displayedComponents: .date)
                } footer: {
                    Text("Ankomstdagen räknas, avresedagen räknas inte — som hotellnätter. Fredag till söndag betyder fredag- och lördagsnatt.")
                }

                Section {
                    Stepper("Antal personer som kommer: \(peopleCount)", value: $peopleCount, in: 1...30)
                    Toggle("Ange sängplatser separat", isOn: $useSeparateBedSpaces)
                    if useSeparateBedSpaces {
                        Stepper("Sängplatser som behövs: \(bedSpacesNeeded)", value: $bedSpacesNeeded, in: 1...30)
                    }
                } footer: {
                    if !useSeparateBedSpaces {
                        Text("Sängplatser antas vara samma som antal personer.")
                    }
                }

                Section("Anteckning") {
                    TextField("Valfri anteckning", text: $note, axis: .vertical)
                        .lineLimit(1...4)
                }
            }
            .navigationTitle(isEditing ? "Redigera vistelse" : "Ny vistelse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Spara") { save() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if var stay = existingStay {
            stay.familyName = trimmedName
            stay.arrivalDate = arrivalDate
            stay.departureDate = departureDate
            stay.peopleCount = peopleCount
            stay.bedSpacesNeeded = useSeparateBedSpaces ? bedSpacesNeeded : nil
            stay.note = trimmedNote.isEmpty ? nil : trimmedNote
            model.updateStay(stay)
        } else {
            model.addStay(
                CottageStay(
                    familyName: trimmedName,
                    arrivalDate: arrivalDate,
                    departureDate: departureDate,
                    peopleCount: peopleCount,
                    bedSpacesNeeded: useSeparateBedSpaces ? bedSpacesNeeded : nil,
                    note: trimmedNote.isEmpty ? nil : trimmedNote
                )
            )
        }
        dismiss()
    }
}

#Preview("Ny vistelse") {
    StayFormView()
        .environment(AppModel(repository: InMemoryCottageRepository()))
}

#Preview("Redigera") {
    StayFormView(existingStay: SampleData.stays.first)
        .environment(AppModel(repository: InMemoryCottageRepository()))
}
