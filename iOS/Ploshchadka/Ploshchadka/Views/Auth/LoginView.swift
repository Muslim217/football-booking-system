import SwiftUI

struct LoginView: View {
    @Environment(AuthStore.self) var authStore

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // White background everywhere
            Color.fbSurface.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Green hero ─────────────────────────────────
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "2C8341"), Color(hex: "145322")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    // Pitch lines
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 2)
                            .padding(.horizontal, 36).padding(.vertical, 18)
                        Circle()
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 2)
                            .frame(width: 70, height: 70)
                    }
                    // Logo + title
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .frame(width: 56, height: 56)
                                .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 4)
                            Text("⚽").font(.system(size: 26))
                        }
                        Text("Площадка")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Text("Система бронирования площадок")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .ignoresSafeArea(edges: .top)

                // ── Form ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 0) {
                    Text("Вход")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.fbText)
                        .padding(.bottom, 6)

                    Text("Введите данные для входа")
                        .font(.system(size: 15))
                        .foregroundColor(.fbTextMuted)
                        .padding(.bottom, 28)

                    FormField(label: "Имя пользователя", placeholder: "username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.bottom, 16)

                    FormSecureField(label: "Пароль", placeholder: "••••••••", text: $password)
                        .padding(.bottom, 28)

                    if let error = errorMessage {
                        ErrorBanner(message: error).padding(.bottom, 16)
                    }

                    PrimaryButton(title: "Войти", isLoading: isLoading) {
                        Task { await login() }
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                    .opacity(username.isEmpty || password.isEmpty ? 0.45 : 1)

                    Spacer()

                    Divider().background(Color.fbBorder).padding(.bottom, 16)

                    HStack(spacing: 4) {
                        Text("Нет аккаунта?")
                            .font(.system(size: 14))
                            .foregroundColor(.fbTextMuted)
                        NavigationLink("Зарегистрируйтесь") { RegisterView() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.fbPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.fbSurface)

                // ── Pitch strip ────────────────────────────────
                PitchStrip()
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationBarHidden(true)
    }

    private func login() async {
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true; errorMessage = nil
        do {
            let response: AuthResponse = try await APIClient.shared.fetch(
                "/auth/login", method: "POST",
                body: LoginRequest(username: username, password: password)
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

// MARK: - Form Field helpers

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.fbText)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundColor(.fbText)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color.fbBg)
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.fbBorder, lineWidth: 1.5))
                .cornerRadius(10)
                .keyboardType(keyboardType)
        }
    }
}

struct FormSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.fbText)
            SecureField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundColor(.fbText)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color.fbBg)
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.fbBorder, lineWidth: 1.5))
                .cornerRadius(10)
        }
    }
}
