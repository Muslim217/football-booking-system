import SwiftUI

struct MainTabView: View {
    @Environment(AuthStore.self) var authStore

    var body: some View {
        TabView {
            NavigationStack {
                FieldsListView()
            }
            .tabItem { Label("Площадки", systemImage: "sportscourt.fill") }

            if authStore.isOwner || authStore.isAdmin {
                NavigationStack {
                    OwnerDashboardView()
                }
                .tabItem { Label("Мои поля", systemImage: "building.2.fill") }
            }

            // All logged-in users can have bookings
            NavigationStack {
                MyBookingsView()
            }
            .tabItem { Label("Брони", systemImage: "calendar.badge.clock") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Профиль", systemImage: "person.circle.fill") }
        }
        .tint(Color.fbPrimary)
    }
}
