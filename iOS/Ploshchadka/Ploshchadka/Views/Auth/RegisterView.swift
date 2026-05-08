import SwiftUI

struct RegisterView: View {
    @Environment(AuthStore.self) var authStore
    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var selectedRole = "USER"
    @State private var isLoading = false
    @State private var errorMessage: String?

    var canSubmit: Bool {
        username.count >= 3 && email.contains("@") && password.count >= 6
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.fbSurface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // ── Green hero ────────────────────────────────
                    ZStack {
                        LinearGradient(
                            colors: [Color(hex: "2C8341"), Color(hex: "145322")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea(edges: .top)

                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 2)
                                .padding(.horizontal, 40).padding(.vertical, 20)
                            Circle()
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 2)
                                .frame(width: 80, height: 80)
                        }

                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .frame(width: 52, height: 52)
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                Text("⚽").font(.system(size: 24))
                            }
                            Text("Площадка")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 170)

                    // ── Form ──────────────────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Регистрация")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.fbText)
                            .padding(.top, 28)
                            .padding(.bottom, 6)

                        Text("Заполните данные для создания аккаунта")
                            .font(.system(size: 15))
                            .foregroundColor(.fbTextMuted)
                            .padding(.bottom, 24)

                        FormField(label: "Имя пользователя", placeholder: "username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.bottom, 16)

                        FormField(label: "Email", placeholder: "you@example.com",
                                  text: $email, keyboardType: .emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.bottom, 16)

                        FormSecureField(label: "Пароль", placeholder: "Минимум 6 символов", text: $password)
                            .padding(.bottom, 20)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Я регистрируюсь как")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.fbText)
                            HStack(spacing: 10) {
                                RoleCard(title: "Клиент",   subtitle: "Бронировать поля",
                                         icon: "person.fill",     value: "USER",  selected: $selectedRole)
                                RoleCard(title: "Владелец", subtitle: "Сдавать поля",
                                         icon: "building.2.fill", value: "OWNER", selected: $selectedRole)
                            }
                        }
                        .padding(.bottom, 24)

                        if let error = errorMessage {
                            ErrorBanner(message: error).padding(.bottom, 16)
                        }

                        PrimaryButton(title: "Создать аккаунт", isLoading: isLoading) {
                            Task { await register() }
                        }
                        .opacity(canSubmit ? 1 : 0.45)
                        .disabled(!canSubmit)

                        Divider().background(Color.fbBorder).padding(.vertical, 24)

                        HStack(spacing: 4) {
                            Text("Уже есть аккаунт?")
                                .font(.system(size: 14))
                                .foregroundColor(.fbTextMuted)
                            Button("Войдите") { dismiss() }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.fbPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 80)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.fbSurface)
                }
            }
            .ignoresSafeArea(edges: .top)

            PitchStrip()
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }

    private func register() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: AuthResponse = try await APIClient.shared.fetch(
                "/auth/register", method: "POST",
                body: RegisterRequest(username: username, email: email, password: password, role: selectedRole)
            )
            authStore.saveAuth(response)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Ошибка соединения с сервером"
        }
        isLoading = false
    }
}

// MARK: - Role Card

private struct RoleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let value: String
    @Binding var selected: String

    private var isSelected: Bool { selected == value }

    var body: some View {
        Button { selected = value } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .fbPrimary : .fbTextMuted)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .fbText : .fbTextMuted)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.fbTextMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(isSelected ? Color.fbPrimarySoft : Color.fbBg)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.fbPrimary : Color.fbBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
