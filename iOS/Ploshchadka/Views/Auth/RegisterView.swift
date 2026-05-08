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
        ZStack {
            Color.fbBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 24)

                    VStack(alignment: .leading, spacing: 0) {
                        // Logo row
                        HStack(spacing: 10) {
                            BrandMark(size: 40)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Площадка")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.fbText)
                                Text("Создайте аккаунт")
                                    .font(.system(size: 12))
                                    .foregroundColor(.fbTextMuted)
                            }
                        }
                        .padding(.bottom, 28)

                        Text("Регистрация")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.fbText)
                        Text("Заполните данные для создания аккаунта")
                            .font(.system(size: 15))
                            .foregroundColor(.fbTextMuted)
                            .padding(.top, 4)
                            .padding(.bottom, 32)

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

                        // Role selector
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
                        .padding(.bottom, 20)

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

            VStack {
                Spacer()
                PitchStrip()
            }
            .ignoresSafeArea()
        }
        .navigationTitle("Регистрация")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func register() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: AuthResponse = try await APIClient.shared.fetch(
                "/auth/register",
                method: "POST",
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
            .background(isSelected ? Color.fbPrimarySoft : Color.fbSurface)
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
