import SwiftUI

struct ContentView: View {
    @Environment(AuthStore.self) var authStore

    var body: some View {
        Group {
            if authStore.isLoggedIn {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authStore.isLoggedIn)
    }
}
