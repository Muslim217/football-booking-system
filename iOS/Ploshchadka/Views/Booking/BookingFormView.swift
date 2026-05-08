import SwiftUI

struct BookingFormView: View {
    let field: Field

    @Environment(\.dismiss) var dismiss

    @State private var startDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State private var endDate   = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var didBook = false

    private var durationHours: Double {
        max(0, endDate.timeIntervalSince(startDate) / 3600)
    }

    private var estimatedPrice: Double {
        durationHours * field.pricePerHour
    }

    private var isValid: Bool { durationHours > 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Field info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(field.name).font(.headline)
                            Text(field.address).font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        FieldTypeBadge(fieldType: field.fieldType)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.05), radius: 6)

                    // Time pickers
                    VStack(spacing: 0) {
                        DatePicker(
                            "Начало",
                            selection: $startDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .padding()
                        .onChange(of: startDate) { newStart in
                            if endDate <= newStart {
                                endDate = Calendar.current.date(byAdding: .hour, value: 1, to: newStart) ?? newStart
                            }
                        }

                        Divider().padding(.horizontal)

                        DatePicker(
                            "Окончание",
                            selection: $endDate,
                            in: startDate...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.05), radius: 6)

                    // Price estimate
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Расчётная стоимость")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Group {
                                if isValid {
                                    Text("\(Int(estimatedPrice)) ₽")
                                        .font(.title2.bold())
                                        .foregroundColor(.green)
                                } else {
                                    Text("—")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Spacer()
                        if isValid {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(format: "%.1f ч", durationHours))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("\(Int(field.pricePerHour)) ₽/ч × \(String(format: "%.1f", durationHours))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.07))
                    .cornerRadius(14)

                    if let error = errorMessage {
                        ErrorBanner(message: error)
                    }

                    if didBook {
                        SuccessBanner(message: "Бронирование создано!")
                    }

                    Button {
                        Task { await book() }
                    } label: {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            Image(systemName: "checkmark.circle.fill")
                            Text("Подтвердить бронирование")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(isValid ? Color.green : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isLoading || !isValid)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Забронировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }

    private func book() async {
        isLoading = true
        errorMessage = nil

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        do {
            let _: Booking = try await APIClient.shared.fetch(
                "/bookings",
                method: "POST",
                body: BookingRequest(
                    fieldId: field.id,
                    startTime: fmt.string(from: startDate),
                    endTime: fmt.string(from: endDate)
                )
            )
            didBook = true
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            dismiss()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Ошибка соединения"
        }
        isLoading = false
    }
}
