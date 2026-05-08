import SwiftUI

struct FieldFormView: View {
    /// Pass nil to create a new field, pass a Field to edit it
    let existing: Field?

    @Environment(\.dismiss) var dismiss

    @State private var name        = ""
    @State private var address     = ""
    @State private var fieldType   = "OUTDOOR"
    @State private var price       = ""
    @State private var description = ""
    @State private var isLoading   = false
    @State private var errorMessage: String?

    private var isEditing: Bool { existing != nil }
    private var title: String    { isEditing ? "Редактировать поле" : "Новое поле" }

    private var canSave: Bool {
        !name.isEmpty && !address.isEmpty && Double(price) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Основное") {
                    TextField("Название", text: $name)
                        .textInputAutocapitalization(.words)
                    TextField("Адрес", text: $address)
                        .textInputAutocapitalization(.words)
                }

                Section("Параметры") {
                    Picker("Тип поля", selection: $fieldType) {
                        Text("Открытое").tag("OUTDOOR")
                        Text("Крытое").tag("INDOOR")
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    HStack {
                        Text("Цена за час (₽)")
                        Spacer()
                        TextField("3 000", text: $price)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }

                Section("Описание") {
                    TextField("Натуральный газон, раздевалки, парковка...",
                              text: $description,
                              axis: .vertical)
                    .lineLimit(3...6)
                }

                if let error = errorMessage {
                    Section { ErrorBanner(message: error) }
                }

                Section {
                    Button {
                        Task { await save() }
                    } label: {
                        HStack {
                            if isLoading { ProgressView() }
                            Spacer()
                            Text(isEditing ? "Сохранить изменения" : "Добавить поле")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .foregroundColor(canSave ? .green : .secondary)
                    .disabled(!canSave || isLoading)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
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
            errorMessage = "Введите корректную цену"
            return
        }

        isLoading = true
        errorMessage = nil

        let body = FieldRequest(
            name: name,
            address: address,
            fieldType: fieldType,
            pricePerHour: priceValue,
            description: description
        )

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
