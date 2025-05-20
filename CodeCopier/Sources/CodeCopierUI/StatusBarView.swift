import SwiftUI

struct StatusBarView: View {
    var body: some View {
        HStack {
            Text("Status Bar")
                .padding()
        }
        .glassBackgroundEffect(in: .window, displayMode: .always)
    }
}
