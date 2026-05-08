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
        ZStack {
            Color.fbBg.ignoresSafeArea()

            if isLoading && bookings.isEmpty {
                ProgressView().tint(Color.fbPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if bookings.isEmpty && errorMessage == nil {
                EmptyStateView(icon: "calendar.badge.exclamationmark",
                               message: "У вас пока нет бронирований")
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        if let error = errorMessage {
                            ErrorBanner(message: error).padding(.horizontal, 16)
                        }
                        ForEach(sorted) { booking in
                            BookingCard(booking: booking) {
                                Task { await cancel(booking.id) }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .refreshable { await load() }
            }
        }
        .navigationTitle("Мои бронирования")
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
        } catch {
            errorMessage = "Ошибка соединения"
        }
    }
}

// MARK: - Booking Card

private struct BookingCard: View {
    let booking: Booking
    let onCancel: () -> Void

    @State private var showAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(booking.fieldName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.fbText)
                Spacer()
                StatusBadge(status: booking.status)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.fbPrimary)
                    Text(booking.startTime.toDisplayDateTime())
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.fbTextMuted)
                }
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.fbDanger.opacity(0.7))
                    Text(booking.endTime.toDisplayDateTime())
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.fbTextMuted)
                }
            }

            Divider().background(Color.fbBorder)

            HStack {
                Text("\(Int(booking.totalPrice)) ₽")
                    .font(.system(size: 17, weight: .bold, design: .monospaced))
                    .foregroundColor(.fbText)
                Spacer()
                if !booking.isCancelled {
                    Button("Отменить") { showAlert = true }
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(Color.fbDangerSoft)
                        .foregroundColor(.fbDanger)
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.fbDanger.opacity(0.25), lineWidth: 1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(18)
        .background(Color.fbSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.fbBorder, lineWidth: 1)
        )
        .cornerRadius(14)
        .shadow(color: Color(hex: "172117").opacity(0.06), radius: 6, x: 0, y: 2)
        .opacity(booking.isCancelled ? 0.55 : 1)
        .alert("Отменить бронирование?", isPresented: $showAlert) {
            Button("Отменить бронирование", role: .destructive) { onCancel() }
            Button("Назад", role: .cancel) {}
        } message: {
            Text("\(booking.fieldName)\n\(booking.startTime.toDisplayDateTime())")
        }
    }
}
