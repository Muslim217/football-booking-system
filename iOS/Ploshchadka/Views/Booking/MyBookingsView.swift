import SwiftUI

struct MyBookingsView: View {
    @State private var bookings: [Booking] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var sorted: [Booking] {
        bookings.sorted {
            if $0.isCancelled != $1.isCancelled { return !$0.isCancelled }
            return $0.startTime > $1.startTime
        }
    }

    var body: some View {
        Group {
            if isLoading && bookings.isEmpty {
                ProgressView("Загружаем бронирования...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if bookings.isEmpty && errorMessage == nil {
                EmptyStateView(icon: "calendar.badge.exclamationmark", message: "У вас пока нет бронирований")
            } else {
                List {
                    if let error = errorMessage {
                        Section { ErrorBanner(message: error) }
                    }
                    ForEach(sorted) { booking in
                        BookingRow(booking: booking) {
                            Task { await cancel(booking.id) }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Мои бронирования")
        .refreshable { await load() }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            bookings = try await APIClient.shared.fetch("/bookings/my")
        } catch let e as APIError {
            errorMessage = e.errorDescription
        } catch {
            errorMessage = "Ошибка загрузки"
        }
        isLoading = false
    }

    private func cancel(_ id: Int64) async {
        do {
            let updated: Booking = try await APIClient.shared.fetch("/bookings/\(id)/cancel", method: "PUT")
            if let idx = bookings.firstIndex(where: { $0.id == id }) {
                bookings[idx] = updated
            }
        } catch let e as APIError {
            errorMessage = e.errorDescription
        }
    }
}

// MARK: - Booking Row

private struct BookingRow: View {
    let booking: Booking
    let onCancel: () -> Void

    @State private var showAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(booking.fieldName)
                    .font(.headline)
                Spacer()
                StatusBadge(status: booking.status)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right.circle.fill").foregroundColor(.green).font(.caption)
                    Text(booking.startTime.toDisplayDateTime()).font(.subheadline)
                }
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red.opacity(0.7)).font(.caption)
                    Text(booking.endTime.toDisplayDateTime()).font(.subheadline)
                }
            }

            HStack {
                Text("\(Int(booking.totalPrice)) ₽")
                    .font(.headline)
                    .foregroundColor(.green)
                Spacer()
                if !booking.isCancelled {
                    Button("Отменить") { showAlert = true }
                        .font(.subheadline)
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .controlSize(.small)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(booking.isCancelled ? 0.5 : 1)
        .alert("Отменить бронирование?", isPresented: $showAlert) {
            Button("Отменить бронирование", role: .destructive) { onCancel() }
            Button("Назад", role: .cancel) {}
        } message: {
            Text("\(booking.fieldName)\n\(booking.startTime.toDisplayDateTime())")
        }
    }
}
