import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authStore: AuthStore
    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "USER"
    @State private var isLoading = false
    @State private var errorMessage: String?

    var canSubmit: Bool {
        username.count >= 3 && email.contains("@") && password.count >= 6
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("⚽").font(.system(size: 52))
                    Text("Регистрация").font(.title.bold())
                    Text("Создайте аккаунт").foregroundColor(.secondary)
                }
                .padding(.top, 20)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Имя пользователя")
                            .font(.subheadline.weight(.medium))
                        TextField("Минимум 3 символа", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.subheadline.weight(.medium))
                        TextField("example@mail.com", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Пароль")
                            .font(.subheadline.weight(.medium))
                        SecureField("Минимум 6 символов", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Role selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Я регистрируюсь как")
                            .font(.subheadline.weight(.medium))
                        HStack(spacing: 12) {
                            RoleCard(
                                title: "Клиент",
                                subtitle: "Бронировать поля",
                                icon: "person.fill",
                                value: "USER",
                                selected: $selectedRole
                            )
                            RoleCard(
                                title: "Владелец",
                                subtitle: "Сдавать поля",
                                icon: "building.2.fill",
                                value: "OWNER",
                                selected: $selectedRole
                            )
                        }
                    }

                    if let error = errorMessage {
                        ErrorBanner(message: error)
                    }

                    PrimaryButton(title: "Создать аккаунт", isLoading: isLoading) {
                        Task { await register() }
                    }
                    .opacity(canSubmit ? 1 : 0.6)
                    .disabled(!canSubmit)
                }
                .padding(.horizontal, 24)

                HStack(spacing: 4) {
                    Text("Уже есть аккаунт?")
                        .foregroundColor(.secondary)
                    Button("Войдите") { dismiss() }
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.bottom, 32)
            }
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
                    .font(.title3)
                    .foregroundColor(isSelected ? .green : .secondary)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(isSelected ? .primary : .secondary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.green.opacity(0.05) : Color(.systemBackground))
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
