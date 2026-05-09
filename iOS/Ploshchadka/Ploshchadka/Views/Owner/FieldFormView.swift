import SwiftUI

struct FieldFormView: View {
    let existing: Field?

    @Environment(\.dismiss) var dismiss

    @State private var name        = ""
    @State private var address     = ""
    @State private var fieldType   = "FOOTBALL"
    @State private var price       = ""
    @State private var description = ""
    @State private var isLoading   = false
    @State private var errorMessage: String?

    private let fieldTypes: [(String, String, String)] = [
        ("FOOTBALL",   "Футбол",    "figure.soccer"),
        ("BASKETBALL", "Баскетбол", "figure.basketball"),
        ("VOLLEYBALL", "Волейбол",  "figure.volleyball"),
        ("TENNIS",     "Теннис",    "figure.tennis"),
        ("PADEL",      "Падел",     "tennis.racket"),
        ("HOCKEY",     "Хоккей",    "figure.hockey"),
        ("INDOOR",     "Крытое",    "building.fill"),
        ("OUTDOOR",    "Открытое",  "sun.max.fill"),
    ]

    private var isEditing: Bool { existing != nil }
    private var title: String    { isEditing ? "Редактировать поле" : "Новое поле" }
    private var canSave: Bool    { !name.isEmpty && !address.isEmpty && Double(price) != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fbBg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {

                        // Basic info
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(title: "Основное")
                            FormField(label: "Название", placeholder: "Стадион Лужники", text: $name)
                                .textInputAutocapitalization(.words)
                            FormField(label: "Адрес", placeholder: "ул. Лужники, 24", text: $address)
                                .textInputAutocapitalization(.words)
                        }
                        .cardStyle()

                        // Field type grid
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(title: "Тип площадки")
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                                ForEach(fieldTypes, id: \.0) { value, label, icon in
                                    let selected = fieldType == value
                                    Button { fieldType = value } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: icon)
                                                .font(.system(size: 14))
                                                .foregroundColor(selected ? .white : .fbTextMuted)
                                            Text(label)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(selected ? .white : .fbText)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selected ? Color.fbPrimary : Color.fbSurface)
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(selected ? Color.fbPrimary : Color.fbBorder,
                                                          lineWidth: selected ? 2 : 1))
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .cardStyle()

                        // Price
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(title: "Параметры")
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Цена за час (₽)")
                                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.fbText)
                                TextField("3 000", text: $price)
                                    .font(.system(size: 15)).keyboardType(.decimalPad)
                                    .padding(.horizontal, 14).padding(.vertical, 11)
                                    .background(Color.fbBg)
                                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.fbBorder, lineWidth: 1.5))
                                    .cornerRadius(10)
                            }
                        }
                        .cardStyle()

                        // Description
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(title: "Описание")
                            TextField("Натуральный газон, раздевалки, парковка…",
                                      text: $description, axis: .vertical)
                                .font(.system(size: 15)).lineLimit(3...6)
                                .padding(.horizontal, 14).padding(.vertical, 11)
                                .background(Color.fbBg)
                                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.fbBorder, lineWidth: 1.5))
                                .cornerRadius(10)
                        }
                        .cardStyle()

                        if let error = errorMessage { ErrorBanner(message: error) }

                        Button { Task { await save() } } label: {
                            HStack(spacing: 8) {
                                if isLoading { ProgressView().tint(.white).scaleEffect(0.85) }
                                Text(isEditing ? "Сохранить изменения" : "Добавить поле")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(canSave ? Color.fbPrimary : Color.fbBorder)
                            .foregroundColor(canSave ? .white : .fbTextMuted)
                            .cornerRadius(10)
                        }
                        .disabled(!canSave || isLoading)
                    }
                    .padding(16)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }.foregroundColor(.fbPrimary)
                }
            }
            .onAppear { prefill() }
        }
    }

    private func prefill() {
        guard let f = existing else { return }
        name        = f.name
        address     = f.address
        fieldType   = f.fieldType
        price       = String(Int(f.pricePerHour))
        description = f.description ?? ""
    }

    private func save() async {
        guard let priceValue = Double(price.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = "Введите корректную цену"; return
        }
        isLoading = true; errorMessage = nil
        let body = FieldRequest(name: name, address: address, fieldType: fieldType,
                                pricePerHour: priceValue, description: description)
        do {
            if let existing {
                let _: Field = try await APIClient.shared.fetch("/fields/\(existing.id)", method: "PUT", body: body)
            } else {
                let _: Field = try await APIClient.shared.fetch("/fields", method: "POST", body: body)
            }
            dismiss()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Ошибка соединения"
        }
        isLoading = false
    }
}

private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title).font(.system(size: 12, weight: .semibold))
            .foregroundColor(.fbTextMuted).textCase(.uppercase).tracking(0.8)
    }
}

private extension View {
    func cardStyle() -> some View {
        self.padding(16)
            .background(Color.fbSurface)
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
            .cornerRadius(14)
            .shadow(color: Color(hex: "172117").opacity(0.05), radius: 6, x: 0, y: 2)
    }
}
