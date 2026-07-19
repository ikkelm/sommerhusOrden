import SwiftUI

/// Gemensam tom-vy för flikar utan innehåll ännu.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        }
    }
}

#Preview {
    EmptyStateView(
        systemImage: "house",
        title: "Inga vistelser",
        message: "Här visas vem som är i stugan och när."
    )
}
