import CloudKit
import SwiftUI
import UIKit

/// SwiftUI-omslag för systemets delnings-UI (UICloudSharingController).
/// Ägaren bjuder in familjen via Kontakter/Meddelanden, kan hantera deltagare
/// och avsluta delningen. Endast läs-och-skriv erbjuds (alla i familjen får redigera).
struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer
    let title: String

    func makeCoordinator() -> Coordinator {
        Coordinator(title: title)
    }

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        // Privat (endast inbjudna) eller länk väljs i systemets UI;
        // läsbehörighet utan skrivrätt erbjuds inte i MVP.
        controller.availablePermissions = [.allowPrivate, .allowPublic, .allowReadWrite]
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}

    final class Coordinator: NSObject, UICloudSharingControllerDelegate {
        let title: String

        init(title: String) {
            self.title = title
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            title
        }

        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            // Systemkontrollen visar redan felet för användaren.
            print("sommerhusOrden: delning kunde inte sparas: \(error.localizedDescription)")
        }

        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {}

        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {}
    }
}
