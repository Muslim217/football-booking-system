import SwiftUI

struct FieldsListView: View {
    @State private var fields: [Field] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var activeFilter = ""

    private let filters = [
        ("", "Все"), ("FOOTBALL", "Футбол"), ("BASKETBALL", "Баскетбол"),
        ("VOLLEYBALL", "Волейбол"), ("TENNIS", "Теннис"),
        ("PADEL", "Падел"), ("HOCKEY", "Хоккей"),
    ]

    var body: some View {
        ZStack {
            Color.fbBg.ignoresSafeArea()

            if isLoading && fields.isEmpty {
                ProgressView().tint(Color.fbPrimary)
            } else if let error = errorMessage, fields.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash").font(.system(size: 40)).foregroundColor(.fbTextFaint)
                    Text(error).font(.system(size: 15)).foregroundColor(.fbTextMuted)
                    Button("Повторить") { Task { await load() } }
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 18).padding(.vertical, 9)
                        .background(Color.fbPrimary).foregroundColor(.white).cornerRadius(8)
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Search
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.fbTextFaint).font(.system(size: 14))
                            TextField("Поиск по названию или адресу…", text: $searchText)
                                .font(.system(size: 14)).foregroundColor(.fbText)
                                .onChange(of: searchText) { _, _ in
                                    Task { await load() }
                                }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 11)
                        .background(Color.fbSurface)
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
                        .cornerRadius(14)
                        .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 10)

                        // Filter chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(filters, id: \.0) { value, label in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.15)) { activeFilter = value }
                                        Task { await load() }
                                    } label: {
                                        Text(label)
                                            .font(.system(size: 13, weight: .semibold))
                                            .padding(.horizontal, 12).padding(.vertical, 7)
                                            .background(activeFilter == value ? Color.fbPrimary : Color.fbSurface)
                                            .foregroundColor(activeFilter == value ? .white : .fbText)
                                            .overlay(RoundedRectangle(cornerRadius: 999)
                                                .strokeBorder(activeFilter == value ? Color.fbPrimary : Color.fbBorder, lineWidth: 1))
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 14)

                        // Count
                        if !fields.isEmpty {
                            HStack {
                                Text("\(fields.count) площадок")
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.fbTextMuted).textCase(.uppercase).tracking(0.8)
                                Spacer()
                            }
                            .padding(.horizontal, 16).padding(.bottom, 10)
                        }

                        // Cards
                        if fields.isEmpty && !isLoading {
                            VStack(spacing: 10) {
                                Text("🏟️").font(.system(size: 40))
                                Text("Площадки не найдены")
                                    .font(.system(size: 16, weight: .bold)).foregroundColor(.fbText)
                                Text("Попробуйте изменить фильтры")
                                    .font(.system(size: 14)).foregroundColor(.fbTextMuted)
                            }
                            .frame(maxWidth: .infinity).padding(.top, 48)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(fields) { field in
                                    NavigationLink { FieldDetailView(field: field) } label: {
                                        FieldCard(field: field)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16).padding(.bottom, 32)
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
        isLoading = true; errorMessage = nil
        // Use server-side filtering
        var path = "/fields?"
        if !activeFilter.isEmpty { path += "type=\(activeFilter)&" }
        if !searchText.isEmpty   { path += "search=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)&" }
        do {
            fields = try await APIClient.shared.fetchPage(path)
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
        HStack(spacing: 12) {
            // Pitch photo
            ZStack(alignment: .bottomLeading) {
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "2C8341"), Color(hex: "1B6B2E")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1.5).padding(6)
                    Circle().strokeBorder(Color.white.opacity(0.2), lineWidth: 1.5).frame(width: 28, height: 28)
                }
                .frame(width: 96, height: 92).cornerRadius(10)

                Text("\(Int(field.pricePerHour)) ₽")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(Color.white).foregroundColor(.fbText)
                    .clipShape(Capsule()).padding(6)
            }
            .frame(width: 96, height: 92)

            // Info
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text(field.name)
                        .font(.system(size: 15, weight: .bold)).foregroundColor(.fbText).lineLimit(1)
                    Spacer()
                    FieldTypeBadge(fieldType: field.fieldType)
                }
                .padding(.bottom, 3)

                HStack(spacing: 4) {
                    Image(systemName: "location.fill").font(.system(size: 10)).foregroundColor(.fbTextFaint)
                    Text(field.address).font(.system(size: 12)).foregroundColor(.fbTextMuted).lineLimit(1)
                }
                .padding(.bottom, 10)

                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("СТОИМОСТЬ")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundColor(.fbTextFaint).tracking(0.6)
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(Int(field.pricePerHour)) ₽")
                                .font(.system(size: 16, weight: .bold)).foregroundColor(.fbText)
                            Text("/час").font(.system(size: 11)).foregroundColor(.fbTextMuted)
                        }
                    }
                    Spacer()
                    Text("Выбрать →")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.fbPrimary).foregroundColor(.white).cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 10).padding(.trailing, 10)
        }
        .background(Color.fbSurface)
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
        .cornerRadius(14)
        .shadow(color: Color(hex: "172117").opacity(0.05), radius: 6, x: 0, y: 2)
        .opacity(field.isActive ? 1 : 0.6)
    }
}
