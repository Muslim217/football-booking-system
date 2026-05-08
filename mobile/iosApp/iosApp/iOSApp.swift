import SwiftUI
import composeApp

@main
struct iOSApp: App {

    init() {
        // Инициализируем Koin для iOS
        KoinInitializerKt.doInitKoin()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
