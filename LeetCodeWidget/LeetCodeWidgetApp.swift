import SwiftUI

@main
struct LeetCodeWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 400)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 600, height: 500)
    }
}
