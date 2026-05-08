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
    private var estimatedPrice: Double { durationHours * field.pricePerHour }
    private var isValid: Bool { durationHours > 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fbBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Field info card
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.fbPrimary.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "sportscourt.fill")
                                    .foregroundColor(.fbPrimary)
                                    .font(.system(size: 20))
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(field.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.fbText)
                                Text(field.address)
                                    .font(.system(size: 13))
                                    .foregroundColor(.fbTextMuted)
                            }
                            Spacer()
                            FieldTypeBadge(fieldType: field.fieldType)
                        }
                        .padding(16)
                        .background(Color.fbSurface)
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
                        .cornerRadius(14)
                        .shadow(color: Color(hex: "172117").opacity(0.05), radius: 6)

                        // Time pickers
                        VStack(spacing: 0) {
                            DatePicker("Начало", selection: $startDate,
                                       in: Date()...,
                                       displayedComponents: [.date, .hourAndMinute])
                                .tint(Color.fbPrimary)
                                .foregroundColor(.fbText)
                                .padding(16)
                                .onChange(of: startDate) { _, newStart in
                                    if endDate <= newStart {
                                        endDate = Calendar.current.date(byAdding: .hour, value: 1, to: newStart) ?? newStart
                                    }
                                }
                            Divider().background(Color.fbBorder).padding(.horizontal, 16)
                            DatePicker("Окончание", selection: $endDate,
                                       in: startDate...,
                                       displayedComponents: [.date, .hourAndMinute])
                                .tint(Color.fbPrimary)
                                .foregroundColor(.fbText)
                                .padding(16)
                        }
                        .background(Color.fbSurface)
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
                        .cornerRadius(14)
                        .shadow(color: Color(hex: "172117").opacity(0.05), radius: 6)

                        // Price estimate
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Расчётная стоимость")
                                    .font(.system(size: 12))
                                    .foregroundColor(.fbTextMuted)
                                if isValid {
                                    Text("\(Int(estimatedPrice)) ₽")
                                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                                        .foregroundColor(.fbText)
                                } else {
                                    Text("—")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(.fbTextFaint)
                                }
                            }
                            Spacer()
                            if isValid {
                                VStack(alignment: .trailing, spacing: 3) {
                                    Text(String(format: "%.1f ч", durationHours))
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.fbTextMuted)
                                    Text("\(Int(field.pricePerHour)) ₽/ч × \(String(format: "%.1f", durationHours))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.fbTextFaint)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.fbSurfaceAlt)
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
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
                            HStack(spacing: 8) {
                                if isLoading { ProgressView().tint(.white).scaleEffect(0.85) }
                                Image(systemName: "checkmark.circle.fill")
                                Text("Подтвердить бронирование")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(isValid ? Color.fbPrimary : Color.fbBorder)
                            .foregroundColor(isValid ? .white : .fbTextMuted)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading || !isValid)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Забронировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.fbPrimary)
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
                "/bookings", method: "POST",
                body: BookingRequest(fieldId: field.id,
                                     startTime: fmt.string(from: startDate),
                                     endTime: fmt.string(from: endDate))
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
