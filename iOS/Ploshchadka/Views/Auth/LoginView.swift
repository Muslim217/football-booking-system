import SwiftUI

struct LoginView: View {
    @Environment(AuthStore.self) var authStore

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.fbBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 48)

                    // Card
                    VStack(alignment: .leading, spacing: 0) {
                        // Logo row
                        HStack(spacing: 10) {
                            BrandMark(size: 40)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Площадка")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.fbText)
                                Text("Войдите в аккаунт")
                                    .font(.system(size: 12))
                                    .foregroundColor(.fbTextMuted)
                            }
                        }
                        .padding(.bottom, 28)

                        Text("Вход")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.fbText)
                        Text("Введите данные для входа в систему")
                            .font(.system(size: 15))
                            .foregroundColor(.fbTextMuted)
                            .padding(.top, 4)
                            .padding(.bottom, 32)

                        // Username
                        FormField(label: "Имя пользователя", placeholder: "username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.bottom, 16)

                        // Password
                        FormSecureField(label: "Пароль", placeholder: "••••••••", text: $password)
                            .padding(.bottom, 20)

                        if let error = errorMessage {
                            ErrorBanner(message: error).padding(.bottom, 16)
                        }

                        PrimaryButton(title: "Войти", isLoading: isLoading) {
                            Task { await login() }
                        }
                        .disabled(username.isEmpty || password.isEmpty)
                        .opacity(username.isEmpty || password.isEmpty ? 0.45 : 1)

                        Divider().background(Color.fbBorder).padding(.vertical, 24)

                        HStack(spacing: 4) {
                            Text("Нет аккаунта?")
                                .font(.system(size: 14))
                                .foregroundColor(.fbTextMuted)
                            NavigationLink("Зарегистрируйтесь") {
                                RegisterView()
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.fbPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(28)
                    .background(Color.fbSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(Color.fbBorder, lineWidth: 1)
                    )
                    .cornerRadius(28)
                    .shadow(color: Color(hex: "172117").opacity(0.12), radius: 32, x: 0, y: 12)
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 40)
                }
            }

            // Pitch strip at bottom
            VStack {
                Spacer()
                PitchStrip()
            }
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }

    private func login() async {
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            let response: AuthResponse = try await APIClient.shared.fetch(
                "/auth/login",
                method: "POST",
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
                .padding(.vertical, 11)
                .background(Color.fbBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.fbBorder, lineWidth: 1.5)
                )
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
                .padding(.vertical, 11)
                .background(Color.fbBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.fbBorder, lineWidth: 1.5)
                )
                .cornerRadius(10)
        }
    }
}
