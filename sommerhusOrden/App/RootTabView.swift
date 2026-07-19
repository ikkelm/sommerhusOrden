import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            StuganView()
                .tabItem {
                    Label("Stugan", systemImage: "house")
                }

            MatView()
                .tabItem {
                    Label("Mat", systemImage: "refrigerator")
                }

            InkopView()
                .tabItem {
                    Label("Inköp", systemImage: "cart")
                }

            InstallningarView()
                .tabItem {
                    Label("Inställningar", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    let model = AppModel(repository: InMemoryCottageRepository())
    return RootTabView()
        .environment(model)
        .environment(CloudKitSyncService(model: model, enabled: false))
}
