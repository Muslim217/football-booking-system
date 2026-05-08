import SwiftUI

struct ProfileView: View {
    @Environment(AuthStore.self) var authStore
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
        case "OWNER": return .fbInfo
        case "ADMIN": return Color(hex: "7C3AED")
        default:      return .fbPrimary
        }
    }

    private var roleBg: Color {
        switch authStore.role {
        case "OWNER": return .fbInfoSoft
        case "ADMIN": return Color(hex: "EDE9FE")
        default:      return .fbPrimarySoft
        }
    }

    var body: some View {
        ZStack {
            Color.fbBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Avatar card
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.fbPrimarySoft)
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.fbPrimary)
                        }
                        VStack(spacing: 6) {
                            Text(authStore.username ?? "")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.fbText)
                            HStack(spacing: 5) {
                                Circle().fill(roleColor).frame(width: 6, height: 6)
                                Text(roleLabel)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(roleBg)
                            .foregroundColor(roleColor)
                            .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(Color.fbSurface)
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.fbBorder, lineWidth: 1))
                    .cornerRadius(20)
                    .shadow(color: Color(hex: "172117").opacity(0.06), radius: 8, x: 0, y: 2)

                    // About section
                    VStack(spacing: 0) {
                        InfoRow(label: "Приложение", value: "Площадка")
                        Divider().background(Color.fbBorder).padding(.horizontal, 16)
                        InfoRow(label: "Версия", value: "1.0.0")
                        Divider().background(Color.fbBorder).padding(.horizontal, 16)
                        InfoRow(label: "Платформа", value: "iOS")
                    }
                    .background(Color.fbSurface)
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
                    .cornerRadius(14)
                    .shadow(color: Color(hex: "172117").opacity(0.05), radius: 6, x: 0, y: 2)

                    // Logout button
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Выйти из аккаунта")
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.fbDangerSoft)
                        .foregroundColor(.fbDanger)
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.fbDanger.opacity(0.25), lineWidth: 1))
                        .cornerRadius(12)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Профиль")
        .alert("Выйти из аккаунта?", isPresented: $showLogoutAlert) {
            Button("Выйти", role: .destructive) { authStore.logout() }
            Button("Отмена", role: .cancel) {}
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.fbTextMuted)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.fbText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
