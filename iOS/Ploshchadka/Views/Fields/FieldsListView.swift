import SwiftUI

struct FieldsListView: View {
    @State private var fields: [Field] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""

    private var filtered: [Field] {
        guard !searchText.isEmpty else { return fields }
        return fields.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.fbBg.ignoresSafeArea()

            if isLoading && fields.isEmpty {
                ProgressView()
                    .tint(Color.fbPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 44))
                        .foregroundColor(.fbTextFaint)
                    Text(error)
                        .font(.system(size: 15))
                        .foregroundColor(.fbTextMuted)
                        .multilineTextAlignment(.center)
                    Button("Повторить") { Task { await load() } }
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Color.fbPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(32)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Search bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.fbTextFaint)
                                .font(.system(size: 15))
                            TextField("Поиск по названию или адресу…", text: $searchText)
                                .font(.system(size: 14))
                                .foregroundColor(.fbText)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color.fbSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.fbBorder, lineWidth: 1.5)
                        )
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                        if filtered.isEmpty {
                            VStack(spacing: 12) {
                                Text("🏟️").font(.system(size: 48))
                                Text("Площадки не найдены")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.fbText)
                                Text("Попробуйте изменить запрос")
                                    .font(.system(size: 14))
                                    .foregroundColor(.fbTextMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(filtered) { field in
                                    NavigationLink {
                                        FieldDetailView(field: field)
                                    } label: {
                                        FieldCard(field: field)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                        }
                    }
                }
                .refreshable { await load() }
            }
        }
        .navigationTitle("Площадки")
        .navigationBarTitleDisplayMode(.large)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            fields = try await APIClient.shared.fetch("/fields")
        } catch let e as APIError {
            errorMessage = e.errorDescription
        } catch {
            errorMessage = "Ошибка соединения"
        }
        isLoading = false
    }
}

// MARK: - Field Card

struct FieldCard: View {
    let field: Field

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Pitch illustration
            ZStack(alignment: .topLeading) {
                FieldPitchView()
                FieldTypeBadge(fieldType: field.fieldType)
                    .padding(10)
            }

            // Card body
            VStack(alignment: .leading, spacing: 8) {
                Text(field.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.fbText)

                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.fbTextFaint)
                    Text(field.address)
                        .font(.system(size: 13))
                        .foregroundColor(.fbTextMuted)
                        .lineLimit(1)
                }

                Divider()
                    .background(Color.fbBorder)
                    .padding(.vertical, 2)

                HStack(alignment: .center) {
                    if let owner = field.ownerUsername {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.fbTextFaint)
                            Text(owner)
                                .font(.system(size: 12))
                                .foregroundColor(.fbTextMuted)
                        }
                    }
                    Spacer()
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("\(Int(field.pricePerHour)) ₽")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.fbText)
                        Text("/час")
                            .font(.system(size: 12))
                            .foregroundColor(.fbTextMuted)
                    }
                    Text("Выбрать время")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.fbPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(16)
        }
        .background(Color.fbSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.fbBorder, lineWidth: 1)
        )
        .cornerRadius(20)
        .shadow(color: Color(hex: "172117").opacity(0.06), radius: 8, x: 0, y: 3)
    }
}
