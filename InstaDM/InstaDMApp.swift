import SwiftUI

@main
struct InstaDMApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black.ignoresSafeArea()
                DMWebView()
            }
            .preferredColorScheme(.dark)
        }
    }
}
