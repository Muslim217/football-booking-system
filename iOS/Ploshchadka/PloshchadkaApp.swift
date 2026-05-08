import SwiftUI

@main
struct PloshchadkaApp: App {
    @State private var authStore = AuthStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authStore)
        }
    }
}
