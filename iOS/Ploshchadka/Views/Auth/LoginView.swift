import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authStore: AuthStore

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero
                VStack(spacing: 10) {
                    Text("⚽")
                        .font(.system(size: 72))
                    Text("Площадка")
                        .font(.largeTitle.bold())
                    Text("Бронирование футбольных полей")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 44)

                // Form
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Имя пользователя")
                            .font(.subheadline.weight(.medium))
                        TextField("Введите имя", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.next)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Пароль")
                            .font(.subheadline.weight(.medium))
                        SecureField("Введите пароль", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .onSubmit { Task { await login() } }
                    }

                    if let error = errorMessage {
                        ErrorBanner(message: error)
                    }

                    PrimaryButton(title: "Войти", isLoading: isLoading) {
                        Task { await login() }
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                    .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1)
                }
                .padding(.horizontal, 24)

                Divider()
                    .padding(.vertical, 32)
                    .padding(.horizontal, 24)

                HStack(spacing: 4) {
                    Text("Нет аккаунта?")
                        .foregroundColor(.secondary)
                    NavigationLink("Зарегистрируйтесь") {
                        RegisterView()
                    }
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.bottom, 40)
            }
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
