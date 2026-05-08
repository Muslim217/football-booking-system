import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authStore: AuthStore

    var body: some View {
        TabView {
            NavigationStack {
                FieldsListView()
            }
            .tabItem {
                Label("Поля", systemImage: "sportscourt.fill")
            }

            if authStore.isOwner {
                NavigationStack {
                    OwnerDashboardView()
                }
                .tabItem {
                    Label("Мои поля", systemImage: "building.2.fill")
                }
            }

            if authStore.isUser || authStore.isAdmin {
                NavigationStack {
                    MyBookingsView()
                }
                .tabItem {
                    Label("Бронирования", systemImage: "calendar.badge.clock")
                }
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Профиль", systemImage: "person.circle.fill")
            }
        }
        .tint(.green)
    }
}
