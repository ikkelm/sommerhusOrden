import CloudKit
import SwiftUI

/// Inställningar: stugans namn, max sängplatser, iCloud-synk och delning.
struct InstallningarView: View {
    @Environment(AppModel.self) private var model
    @Environment(CloudKitSyncService.self) private var syncService

    /// Identifiable-omslag så att delningen kan visas via .sheet(item:).
    private struct SharePresentation: Identifiable {
        let id = UUID()
        let share: CKShare
        let container: CKContainer
    }

    @State private var sharePresentation: SharePresentation?

    var body: some View {
        @Bindable var model = model

        NavigationStack {
            Form {
                Section("Stugan") {
                    TextField("Stugans namn", text: $model.settings.cottageName)
                    Stepper(
                        "Max antal sängplatser: \(model.settings.maxBedSpaces)",
                        value: $model.settings.maxBedSpaces,
                        in: 1...30
                    )
                }

                Section {
                    Label {
                        Text(syncService.availability.displayText)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: syncIcon)
                            .foregroundStyle(syncIconColor)
                    }
                    if let lastSync = syncService.lastSyncDate {
                        LabeledContent("Senast synkad") {
                            Text(lastSync.formatted(.relative(presentation: .named)))
                        }
                        .font(.subheadline)
                    }
                    if syncService.availability == .available {
                        shareRow
                    }
                } header: {
                    Text("iCloud-synk")
                } footer: {
                    Text("Alla i familjen som gått med via inbjudan ser och kan ändra samma vistelser, förråd och inköpslista. Deltagare hanteras under Dela med familjen.")
                }

                Section("Om appen") {
                    LabeledContent("Version", value: appVersion)
                    Text("sommerhusOrden hjälper familjen att samordna stugan — utan gruppchattar och dubbelinköp. Inga annonser, ingen spårning.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Inställningar")
            .sheet(item: $sharePresentation) { presentation in
                CloudSharingView(
                    share: presentation.share,
                    container: presentation.container,
                    title: model.settings.cottageName
                )
                .ignoresSafeArea()
            }
        }
    }

    // MARK: - Delning

    private var shareRow: some View {
        Button {
            Task {
                guard let share = await syncService.fetchOrCreateShare(title: model.settings.cottageName),
                      let container = syncService.cloudKitContainer
                else { return }
                sharePresentation = SharePresentation(share: share, container: container)
            }
        } label: {
            if syncService.isPreparingShare {
                HStack {
                    ProgressView()
                    Text("Förbereder delning …")
                }
            } else {
                Label("Dela med familjen", systemImage: "person.badge.plus")
            }
        }
        .disabled(syncService.isPreparingShare)
    }

    private var syncIcon: String {
        switch syncService.availability {
        case .available: "checkmark.icloud"
        case .unknown: "icloud"
        case .disabled: "icloud.slash"
        default: "exclamationmark.icloud"
        }
    }

    private var syncIconColor: Color {
        switch syncService.availability {
        case .available: .green
        case .unknown, .disabled: .secondary
        default: .orange
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}

#Preview {
    let model = AppModel(repository: InMemoryCottageRepository())
    return InstallningarView()
        .environment(model)
        .environment(CloudKitSyncService(model: model, enabled: false))
}
