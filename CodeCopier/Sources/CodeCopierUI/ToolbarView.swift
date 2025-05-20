import SwiftUI

struct ToolbarView: View {
    var body: some View {
        HStack {
            Text("Toolbar")
                .padding()
        }
        .glassBackgroundEffect(in: .window, displayMode: .always)
    }
}
