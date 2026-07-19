import Foundation

/// Persistens för CloudKit-synkens interna tillstånd:
/// CKSyncEngine-state, arkiverade CKRecord-systemfält och eventuell delad zon.
final class SyncStateStore {
    struct StateData: Codable {
        var privateEngineState: Data?
        var sharedEngineState: Data?
        /// recordName -> arkiverade systemfält (NSKeyedArchiver).
        var recordSystemFields: [String: Data] = [:]
        /// Delad zon om användaren gått med i någon annans stuga.
        var sharedZoneName: String?
        var sharedZoneOwner: String?
    }

    private let fileURL: URL
    private let lock = NSLock()
    private var _data: StateData

    /// Trådsäker läsning; skrivning sker via update(_:).
    var data: StateData {
        lock.lock()
        defer { lock.unlock() }
        return _data
    }

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL()
        if let raw = try? Data(contentsOf: self.fileURL),
           let decoded = try? JSONDecoder().decode(StateData.self, from: raw) {
            self._data = decoded
        } else {
            self._data = StateData()
        }
    }

    static func defaultFileURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = base.appendingPathComponent("sommerhusOrden", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("sync-state.json")
    }

    func update(_ mutate: (inout StateData) -> Void) {
        lock.lock()
        mutate(&_data)
        let snapshot = _data
        lock.unlock()
        persist(snapshot)
    }

    private func persist(_ snapshot: StateData) {
        guard let raw = try? JSONEncoder().encode(snapshot) else { return }
        try? raw.write(to: fileURL, options: .atomic)
    }
}
