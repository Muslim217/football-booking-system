import SwiftUI

struct FieldsListView: View {
    @State private var fields: [Field] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var currentPage = 0
    @State private var hasMore = true

    var body: some View {
        Group {
            if isLoading && fields.isEmpty {
                ProgressView("Загружаем поля...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(error).foregroundColor(.secondary)
                    Button("Повторить") { Task { await reload() } }
                        .buttonStyle(.bordered).tint(.green)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if fields.isEmpty {
                EmptyStateView(icon: "sportscourt", message: "Нет доступных полей")
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(fields) { field in
                            NavigationLink {
                                FieldDetailView(field: field)
                            } label: {
                                FieldCard(field: field)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if field.id == fields.last?.id && hasMore {
                                    Task { await loadNextPage() }
                                }
                            }
                        }
                        if isLoading && !fields.isEmpty {
                            ProgressView().padding()
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Площадка ⚽")
        .refreshable { await reload() }
        .task { await reload() }
    }

    private func reload() async {
        currentPage = 0
        hasMore = true
        fields = []
        await loadNextPage()
    }

    private func loadNextPage() async {
        guard hasMore && !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            // Try paginated response first, fall back to plain array
            let page: Page<Field> = try await APIClient.shared.fetch("/fields?page=\(currentPage)&size=20")
            fields += page.content
            hasMore = !page.last
            currentPage += 1
        } catch {
            // Fallback: some versions of the API might return a plain array
            do {
                let list: [Field] = try await APIClient.shared.fetch("/fields")
                fields = list
                hasMore = false
            } catch let e as APIError {
                errorMessage = e.errorDescription
            } catch {
                errorMessage = "Ошибка соединения"
            }
        }
        isLoading = false
    }
}

// MARK: - Field Card

struct FieldCard: View {
    let field: Field

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Colored top stripe
            Rectangle()
                .fill(field.isIndoor
                      ? LinearGradient(colors: [.blue.opacity(0.7), .blue.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
                      : LinearGradient(colors: [Color(red: 0.18, green: 0.6, blue: 0.3), .green.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                .frame(height: 5)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(field.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Label(field.address, systemImage: "location.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .labelStyle(.titleAndIcon)
                    }
                    Spacer()
                    FieldTypeBadge(fieldType: field.fieldType)
                }

                if let desc = field.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Divider()

                HStack {
                    if let owner = field.ownerUsername {
                        Label(owner, systemImage: "person.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(Int(field.pricePerHour)) ₽")
                        .font(.title3.bold())
                        .foregroundColor(.green)
                    + Text("/час")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 3)
    }
}
