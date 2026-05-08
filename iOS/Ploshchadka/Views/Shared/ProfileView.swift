import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authStore: AuthStore
    @State private var showLogoutAlert = false

    private var roleLabel: String {
        switch authStore.role {
        case "OWNER": return "Владелец"
        case "ADMIN": return "Администратор"
        default:      return "Клиент"
        }
    }

    private var roleColor: Color {
        switch authStore.role {
        case "OWNER": return .blue
        case "ADMIN": return .purple
        default:      return .green
        }
    }

    var body: some View {
        List {
            // Avatar section
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 72, height: 72)
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(authStore.username ?? "")
                            .font(.title3.bold())
                        Text(roleLabel)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(roleColor.opacity(0.12))
                            .foregroundColor(roleColor)
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("О приложении") {
                LabeledContent("Приложение", value: "Площадка")
                LabeledContent("Версия", value: "1.0.0")
                LabeledContent("Платформа", value: "iOS")
            }

            Section {
                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Выйти из аккаунта", systemImage: "rectangle.portrait.and.arrow.right")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Профиль")
        .alert("Выйти из аккаунта?", isPresented: $showLogoutAlert) {
            Button("Выйти", role: .destructive) { authStore.logout() }
            Button("Отмена", role: .cancel) {}
        }
    }
}
