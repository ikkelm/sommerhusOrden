import CloudKit
import SwiftUI

@main
struct SommerhusOrdenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @State private var model: AppModel
    @State private var syncService: CloudKitSyncService

    init() {
        let model = AppModel(repository: LocalFileCottageRepository())
        // Synk stängs av under tester så att XCTest inte rör iCloud.
        let isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let sync = CloudKitSyncService(model: model, enabled: !isRunningTests)
        model.syncService = sync
        _model = State(initialValue: model)
        _syncService = State(initialValue: sync)
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(model)
                .environment(syncService)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await syncService.refreshAccountStatus()
                    await syncService.fetchChanges()
                }
            }
        }
    }
}

/// Behövs för att ta emot CloudKit-delningsinbjudningar via SceneDelegate.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        CloudKitSyncService.current?.acceptShare(metadata: cloudKitShareMetadata)
    }
}
