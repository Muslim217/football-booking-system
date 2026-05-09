import SwiftUI

struct ProfileView: View {
    @Environment(AuthStore.self) var authStore
    @State private var profile: UserProfile?
    @State private var isLoading = false
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
                            Circle().fill(Color.fbPrimarySoft).frame(width: 80, height: 80)
                            Image(systemName: "person.fill")
                                .font(.system(size: 36)).foregroundColor(.fbPrimary)
                        }
                        VStack(spacing: 6) {
                            Text(authStore.username ?? "")
                                .font(.system(size: 20, weight: .bold)).foregroundColor(.fbText)
                            if let email = profile?.email {
                                Text(email).font(.system(size: 13)).foregroundColor(.fbTextMuted)
                            }
                            HStack(spacing: 5) {
                                Circle().fill(roleColor).frame(width: 6, height: 6)
                                Text(roleLabel).font(.system(size: 12, weight: .semibold))
                            }
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(roleBg).foregroundColor(roleColor).clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 28)
                    .background(Color.fbSurface)
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.fbBorder, lineWidth: 1))
                    .cornerRadius(20)
                    .shadow(color: Color(hex: "172117").opacity(0.06), radius: 8, x: 0, y: 2)

                    // Profile details
                    VStack(spacing: 0) {
                        if let fullName = profile?.fullName, !fullName.isEmpty {
                            InfoRow(icon: "person.fill", label: "Имя", value: fullName)
                            Divider().background(Color.fbBorder).padding(.horizontal, 16)
                        }
                        if let phone = profile?.phone, !phone.isEmpty {
                            InfoRow(icon: "phone.fill", label: "Телефон", value: phone)
                            Divider().background(Color.fbBorder).padding(.horizontal, 16)
                        }
                        if let createdAt = profile?.createdAt {
                            InfoRow(icon: "calendar", label: "Аккаунт с",
                                    value: createdAt.toDisplayDate())
                            Divider().background(Color.fbBorder).padding(.horizontal, 16)
                        }
                        InfoRow(icon: "iphone", label: "Платформа", value: "iOS")
                        Divider().background(Color.fbBorder).padding(.horizontal, 16)
                        InfoRow(icon: "info.circle", label: "Версия", value: "1.0.0")
                    }
                    .background(Color.fbSurface)
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
                    .cornerRadius(14)
                    .shadow(color: Color(hex: "172117").opacity(0.05), radius: 6, x: 0, y: 2)

                    // Logout
                    Button(role: .destructive) { showLogoutAlert = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Выйти из аккаунта").fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(Color.fbDangerSoft).foregroundColor(.fbDanger)
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.fbDanger.opacity(0.25), lineWidth: 1))
                        .cornerRadius(12)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Профиль")
        .task { await loadProfile() }
        .alert("Выйти из аккаунта?", isPresented: $showLogoutAlert) {
            Button("Выйти", role: .destructive) { authStore.logout() }
            Button("Отмена", role: .cancel) {}
        }
    }

    private func loadProfile() async {
        guard !isLoading else { return }
        isLoading = true
        profile = try? await APIClient.shared.fetch("/users/me")
        isLoading = false
    }
}

private struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13)).foregroundColor(.fbTextFaint).frame(width: 18)
            Text(label).font(.system(size: 14)).foregroundColor(.fbTextMuted)
            Spacer()
            Text(value).font(.system(size: 14, weight: .medium)).foregroundColor(.fbText)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

private extension String {
    func toDisplayDate() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let d = f.date(from: self) else { return self }
        let out = DateFormatter(); out.dateFormat = "d MMMM yyyy"; out.locale = Locale(identifier: "ru_RU")
        return out.string(from: d)
    }
}
