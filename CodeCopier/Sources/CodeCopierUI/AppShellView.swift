import SwiftUI

public struct AppShellView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ToolbarView()
            TokenDashboardView()
            StatusBarView()
        }
        .accentColor(BrandColors.accent)
    }
}

struct TokenDashboardView: View {
    var body: some View {
        VStack {
            Text("Token Dashboard")
                .padding()
        }
        .glassBackgroundEffect(in: .window, displayMode: .always)
    }
}
