import CloudKit
import Foundation
import Observation

/// iCloud/CloudKit-synk för familjens delade data, byggd på CKSyncEngine.
///
/// MVP-regler (se docs/08_CLOUDKIT_SYNC_RULES.md):
/// - Litet betrott familjesällskap; alla får redigera allt.
/// - Last-writer-wins per fält via updatedAt.
/// - Stabila UUID-baserade recordnamn förhindrar dubbletter.
/// - Appen fungerar offline; synk sker när iCloud är tillgängligt.
///
/// Ägaren synkar sin privata databas (egen zon) och kan dela hela zonen
/// med familjen via en CKShare-länk. Inbjudna synkar samma zon via den
/// delade databasen.
/// @unchecked Sendable: observerbara egenskaper muteras enbart via MainActor,
/// och SyncStateStore är låsskyddad. CKSyncEngineDelegate kräver Sendable.
@Observable
final class CloudKitSyncService: @unchecked Sendable {
    static let containerIdentifier = "iCloud.se.mikkelwulff.sommerhusOrden"
    static let zoneName = "SommerhusZone"

    /// Refereras från SceneDelegate vid accepterad delningsinbjudan.
    static weak var current: CloudKitSyncService?

    enum Availability: Equatable {
        case disabled
        case unknown
        case available
        case noAccount
        case restricted
        case error(String)

        /// Kort svensk statustext för Inställningar.
        var displayText: String {
            switch self {
            case .disabled: "Synk är avstängd i den här byggversionen."
            case .unknown: "Kontrollerar iCloud …"
            case .available: "iCloud är anslutet. Ändringar synkas automatiskt."
            case .noAccount, .restricted:
                "iCloud behövs för att synka med familjen. Du kan fortfarande se lokala data om de finns på enheten."
            case .error(let message): "Synkproblem: \(message)"
            }
        }
    }

    private(set) var availability: Availability = .unknown
    private(set) var lastSyncDate: Date?
    private(set) var isPreparingShare = false

    @ObservationIgnored private weak var model: AppModel?
    @ObservationIgnored private let stateStore: SyncStateStore
    @ObservationIgnored private var container: CKContainer?
    @ObservationIgnored private var privateEngine: CKSyncEngine?
    @ObservationIgnored private var sharedEngine: CKSyncEngine?

    let isEnabled: Bool

    init(model: AppModel, enabled: Bool, stateStore: SyncStateStore = SyncStateStore()) {
        self.model = model
        self.stateStore = stateStore
        self.isEnabled = enabled
        Self.current = self

        guard enabled else {
            availability = .disabled
            return
        }

        let container = CKContainer(identifier: Self.containerIdentifier)
        self.container = container
        startEngines()

        Task { [weak self] in
            await self?.refreshAccountStatus()
            await self?.fetchChanges()
        }
    }

    // MARK: - Zoner

    private var privateZoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: Self.zoneName, ownerName: CKCurrentUserDefaultName)
    }

    /// Zon dit nya records skrivs: den delade zonen om vi är inbjuden deltagare,
    /// annars vår egen privata zon.
    private var activeZoneID: CKRecordZone.ID {
        if let name = stateStore.data.sharedZoneName, let owner = stateStore.data.sharedZoneOwner {
            return CKRecordZone.ID(zoneName: name, ownerName: owner)
        }
        return privateZoneID
    }

    private var isShareParticipant: Bool {
        stateStore.data.sharedZoneName != nil
    }

    private func engine(for zoneID: CKRecordZone.ID) -> CKSyncEngine? {
        zoneID.ownerName == CKCurrentUserDefaultName ? privateEngine : sharedEngine
    }

    // MARK: - Motorer

    private func startEngines() {
        guard let container else { return }

        var privateConfig = CKSyncEngine.Configuration(
            database: container.privateCloudDatabase,
            stateSerialization: decodeState(stateStore.data.privateEngineState),
            delegate: self
        )
        privateConfig.automaticallySync = true
        privateEngine = CKSyncEngine(privateConfig)

        var sharedConfig = CKSyncEngine.Configuration(
            database: container.sharedCloudDatabase,
            stateSerialization: decodeState(stateStore.data.sharedEngineState),
            delegate: self
        )
        sharedConfig.automaticallySync = true
        sharedEngine = CKSyncEngine(sharedConfig)

        // Se till att vår zon finns om vi är ägare.
        if !isShareParticipant {
            privateEngine?.state.add(pendingDatabaseChanges: [
                .saveZone(CKRecordZone(zoneID: privateZoneID))
            ])
        }
    }

    private func decodeState(_ data: Data?) -> CKSyncEngine.State.Serialization? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(CKSyncEngine.State.Serialization.self, from: data)
    }

    private func persistState(_ serialization: CKSyncEngine.State.Serialization, isShared: Bool) {
        let encoded = try? JSONEncoder().encode(serialization)
        stateStore.update { data in
            if isShared {
                data.sharedEngineState = encoded
            } else {
                data.privateEngineState = encoded
            }
        }
    }

    func refreshAccountStatus() async {
        guard let container else { return }
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                switch status {
                case .available: availability = .available
                case .noAccount: availability = .noAccount
                case .restricted, .temporarilyUnavailable: availability = .restricted
                case .couldNotDetermine: availability = .unknown
                @unknown default: availability = .unknown
                }
            }
        } catch {
            await MainActor.run { availability = .error(error.localizedDescription) }
        }
    }

    /// Hämta ändringar manuellt, t.ex. när appen blir aktiv.
    func fetchChanges() async {
        guard isEnabled, availability == .available || availability == .unknown else { return }
        try? await privateEngine?.fetchChanges()
        try? await sharedEngine?.fetchChanges()
    }

    // MARK: - Lokala ändringar in i kön

    func queueSaveStay(_ id: UUID) {
        queueSave(recordName: CloudKitRecordMapping.recordName(forStay: id))
    }

    func queueSaveInventory(_ id: UUID) {
        queueSave(recordName: CloudKitRecordMapping.recordName(forInventory: id))
    }

    func queueSaveShopping(_ id: UUID) {
        queueSave(recordName: CloudKitRecordMapping.recordName(forShopping: id))
    }

    func queueSaveSettings() {
        queueSave(recordName: CloudKitRecordMapping.settingsRecordName)
    }

    func queueDeleteStay(_ id: UUID) {
        queueDelete(recordName: CloudKitRecordMapping.recordName(forStay: id))
    }

    func queueDeleteInventory(_ id: UUID) {
        queueDelete(recordName: CloudKitRecordMapping.recordName(forInventory: id))
    }

    func queueDeleteShopping(_ id: UUID) {
        queueDelete(recordName: CloudKitRecordMapping.recordName(forShopping: id))
    }

    private func queueSave(recordName: String) {
        guard isEnabled else { return }
        let recordID = knownRecordID(for: recordName) ?? CKRecord.ID(recordName: recordName, zoneID: activeZoneID)
        engine(for: recordID.zoneID)?.state.add(pendingRecordZoneChanges: [.saveRecord(recordID)])
    }

    private func queueDelete(recordName: String) {
        guard isEnabled else { return }
        let recordID = knownRecordID(for: recordName) ?? CKRecord.ID(recordName: recordName, zoneID: activeZoneID)
        stateStore.update { $0.recordSystemFields[recordName] = nil }
        engine(for: recordID.zoneID)?.state.add(pendingRecordZoneChanges: [.deleteRecord(recordID)])
    }

    /// RecordID från arkiverade systemfält om det finns; annars nil.
    private func knownRecordID(for recordName: String) -> CKRecord.ID? {
        guard let archived = stateStore.data.recordSystemFields[recordName],
              let record = CloudKitRecordMapping.recordFromArchivedSystemFields(archived)
        else { return nil }
        return record.recordID
    }

    // MARK: - Records ut ur modellen

    /// Bygger CKRecord för uppladdning; nil om objektet inte längre finns lokalt.
    private func record(for recordID: CKRecord.ID) async -> CKRecord? {
        guard let model, let parsed = CloudKitRecordMapping.parse(recordName: recordID.recordName) else { return nil }

        let base: CKRecord
        if let archived = stateStore.data.recordSystemFields[recordID.recordName],
           let restored = CloudKitRecordMapping.recordFromArchivedSystemFields(archived) {
            base = restored
        } else {
            base = CKRecord(recordType: recordType(for: parsed), recordID: recordID)
        }

        return await MainActor.run {
            switch parsed {
            case .stay(let id):
                guard let stay = model.stays.first(where: { $0.id == id }) else { return nil }
                CloudKitRecordMapping.populate(base, with: stay)
            case .inventory(let id):
                guard let item = model.inventoryItems.first(where: { $0.id == id }) else { return nil }
                CloudKitRecordMapping.populate(base, with: item)
            case .shopping(let id):
                guard let item = model.shoppingItems.first(where: { $0.id == id }) else { return nil }
                CloudKitRecordMapping.populate(base, with: item)
            case .settings:
                CloudKitRecordMapping.populate(base, with: model.settings)
            }
            return base
        }
    }

    private func recordType(for parsed: CloudKitRecordMapping.ParsedRecordName) -> CKRecord.RecordType {
        switch parsed {
        case .stay: CloudKitRecordMapping.stayType
        case .inventory: CloudKitRecordMapping.inventoryType
        case .shopping: CloudKitRecordMapping.shoppingType
        case .settings: CloudKitRecordMapping.settingsType
        }
    }

    // MARK: - Fjärrändringar in i modellen

    private func applyRemoteRecord(_ record: CKRecord) async {
        stateStore.update {
            $0.recordSystemFields[record.recordID.recordName] = CloudKitRecordMapping.archiveSystemFields(of: record)
        }

        guard let model else { return }
        await MainActor.run {
            switch CloudKitRecordMapping.parse(recordName: record.recordID.recordName) {
            case .stay(let id):
                guard let remote = CloudKitRecordMapping.stay(from: record) else { return }
                if let index = model.stays.firstIndex(where: { $0.id == id }) {
                    // Last-writer-wins: behåll lokal version bara om den är nyare.
                    if model.stays[index].updatedAt <= remote.updatedAt {
                        model.stays[index] = remote
                    }
                } else {
                    model.stays.append(remote)
                }
            case .inventory(let id):
                guard let remote = CloudKitRecordMapping.inventoryItem(from: record) else { return }
                if let index = model.inventoryItems.firstIndex(where: { $0.id == id }) {
                    if model.inventoryItems[index].lastUpdatedAt <= remote.lastUpdatedAt {
                        model.inventoryItems[index] = remote
                    }
                } else {
                    model.inventoryItems.append(remote)
                }
            case .shopping(let id):
                guard let remote = CloudKitRecordMapping.shoppingItem(from: record) else { return }
                if let index = model.shoppingItems.firstIndex(where: { $0.id == id }) {
                    if model.shoppingItems[index].updatedAt <= remote.updatedAt {
                        model.shoppingItems[index] = remote
                    }
                } else {
                    model.shoppingItems.append(remote)
                }
            case .settings:
                if model.settings.updatedAt <= (record["updatedAt"] as? Date ?? .distantPast) {
                    model.applyRemoteSettings(CloudKitRecordMapping.settings(from: record, mergingInto: model.settings))
                }
            case nil:
                break
            }
        }
    }

    private func applyRemoteDeletion(recordName: String) async {
        stateStore.update { $0.recordSystemFields[recordName] = nil }
        guard let model else { return }
        await MainActor.run {
            switch CloudKitRecordMapping.parse(recordName: recordName) {
            case .stay(let id): model.stays.removeAll { $0.id == id }
            case .inventory(let id): model.inventoryItems.removeAll { $0.id == id }
            case .shopping(let id): model.shoppingItems.removeAll { $0.id == id }
            case .settings, nil: break
            }
        }
    }

    // MARK: - Delning

    /// CKContainer för UICloudSharingController.
    var cloudKitContainer: CKContainer? { container }

    /// Hämtar befintlig zonomfattande delning eller skapar en ny.
    /// Deltagare bjuds in via systemets delnings-UI (UICloudSharingController);
    /// standard är privat delning där bara inbjudna kommer åt datat.
    func fetchOrCreateShare(title: String) async -> CKShare? {
        guard let container, !isShareParticipant else { return nil }
        await MainActor.run { isPreparingShare = true }
        defer { Task { await MainActor.run { self.isPreparingShare = false } } }

        do {
            let database = container.privateCloudDatabase
            let shareRecordID = CKRecord.ID(
                recordName: CKRecordNameZoneWideShare,
                zoneID: privateZoneID
            )
            if let existing = try? await database.record(for: shareRecordID) as? CKShare {
                return existing
            }

            // Säkerställ att zonen finns innan delningen sparas.
            _ = try await database.modifyRecordZones(saving: [CKRecordZone(zoneID: privateZoneID)], deleting: [])

            let share = CKShare(recordZoneID: privateZoneID)
            share.publicPermission = .none
            share[CKShare.SystemFieldKey.title] = title as CKRecordValue

            let result = try await database.modifyRecords(saving: [share], deleting: [])
            for (_, saveResult) in result.saveResults {
                if case .success(let saved) = saveResult, let savedShare = saved as? CKShare {
                    return savedShare
                }
            }
            return nil
        } catch {
            await MainActor.run { availability = .error(error.localizedDescription) }
            return nil
        }
    }

    /// Anropas från SceneDelegate när användaren öppnar en delningslänk.
    func acceptShare(metadata: CKShare.Metadata) {
        guard let container else { return }
        Task {
            do {
                try await container.accept(metadata)
                let zoneID = metadata.share.recordID.zoneID
                stateStore.update {
                    $0.sharedZoneName = zoneID.zoneName
                    $0.sharedZoneOwner = zoneID.ownerName
                }
                try? await sharedEngine?.fetchChanges()
            } catch {
                await MainActor.run { availability = .error(error.localizedDescription) }
            }
        }
    }
}

// MARK: - CKSyncEngineDelegate

extension CloudKitSyncService: CKSyncEngineDelegate {
    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        let isShared = syncEngine === sharedEngine

        switch event {
        case .stateUpdate(let stateUpdate):
            persistState(stateUpdate.stateSerialization, isShared: isShared)

        case .accountChange(let accountChange):
            switch accountChange.changeType {
            case .signIn:
                await MainActor.run { availability = .available }
            case .signOut, .switchAccounts:
                await MainActor.run { availability = .noAccount }
            @unknown default:
                break
            }

        case .fetchedDatabaseChanges(let changes):
            // Zon raderad eller delning avslutad: rensa deltagartillstånd.
            for deletion in changes.deletions {
                let zoneID = deletion.zoneID
                if zoneID.zoneName == stateStore.data.sharedZoneName,
                   zoneID.ownerName == stateStore.data.sharedZoneOwner {
                    stateStore.update {
                        $0.sharedZoneName = nil
                        $0.sharedZoneOwner = nil
                    }
                }
            }

        case .fetchedRecordZoneChanges(let changes):
            for modification in changes.modifications {
                await applyRemoteRecord(modification.record)
            }
            for deletion in changes.deletions {
                await applyRemoteDeletion(recordName: deletion.recordID.recordName)
            }
            await MainActor.run { lastSyncDate = .now }

        case .sentRecordZoneChanges(let sent):
            for saved in sent.savedRecords {
                stateStore.update {
                    $0.recordSystemFields[saved.recordID.recordName] = CloudKitRecordMapping.archiveSystemFields(of: saved)
                }
            }
            for failure in sent.failedRecordSaves {
                await handleFailedSave(failure, syncEngine: syncEngine)
            }
            await MainActor.run { lastSyncDate = .now }

        case .sentDatabaseChanges,
             .willFetchChanges, .didFetchChanges,
             .willFetchRecordZoneChanges, .didFetchRecordZoneChanges,
             .willSendChanges, .didSendChanges:
            break

        @unknown default:
            break
        }
    }

    private func handleFailedSave(
        _ failure: CKSyncEngine.Event.SentRecordZoneChanges.FailedRecordSave,
        syncEngine: CKSyncEngine
    ) async {
        let record = failure.record
        switch failure.error.code {
        case .serverRecordChanged:
            // Konflikt: last-writer-wins via updatedAt.
            guard let serverRecord = failure.error.serverRecord else { return }
            let localUpdated = record["updatedAt"] as? Date ?? record["lastUpdatedAt"] as? Date ?? .distantPast
            let serverUpdated = serverRecord["updatedAt"] as? Date ?? serverRecord["lastUpdatedAt"] as? Date ?? .distantPast

            stateStore.update {
                $0.recordSystemFields[record.recordID.recordName] = CloudKitRecordMapping.archiveSystemFields(of: serverRecord)
            }
            if localUpdated > serverUpdated {
                // Vår ändring är nyare: skriv om den ovanpå serverns version.
                syncEngine.state.add(pendingRecordZoneChanges: [.saveRecord(record.recordID)])
            } else {
                await applyRemoteRecord(serverRecord)
            }

        case .zoneNotFound:
            syncEngine.state.add(pendingDatabaseChanges: [.saveZone(CKRecordZone(zoneID: record.recordID.zoneID))])
            syncEngine.state.add(pendingRecordZoneChanges: [.saveRecord(record.recordID)])

        case .unknownItem:
            // Recordet finns inte längre på servern; skapa om utan gamla systemfält.
            stateStore.update { $0.recordSystemFields[record.recordID.recordName] = nil }
            syncEngine.state.add(pendingRecordZoneChanges: [.saveRecord(record.recordID)])

        case .networkFailure, .networkUnavailable, .serviceUnavailable, .requestRateLimited, .zoneBusy:
            // Övergående fel: CKSyncEngine försöker igen själv.
            break

        default:
            await MainActor.run { availability = .error(failure.error.localizedDescription) }
        }
    }

    func nextRecordZoneChangeBatch(
        _ context: CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) async -> CKSyncEngine.RecordZoneChangeBatch? {
        let scope = context.options.scope
        let pending = syncEngine.state.pendingRecordZoneChanges.filter { scope.contains($0) }
        guard !pending.isEmpty else { return nil }

        return await CKSyncEngine.RecordZoneChangeBatch(pendingChanges: pending) { recordID in
            if let record = await self.record(for: recordID) {
                return record
            }
            // Objektet finns inte längre lokalt; ta bort ur kön.
            syncEngine.state.remove(pendingRecordZoneChanges: [.saveRecord(recordID)])
            return nil
        }
    }
}
