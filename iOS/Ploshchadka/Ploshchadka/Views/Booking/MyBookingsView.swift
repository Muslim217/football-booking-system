import SwiftUI

struct MyBookingsView: View {
    @State private var bookings: [Booking] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var activeTab = 0  // 0 = Предстоящие, 1 = Прошедшие

    private var upcoming: [Booking] {
        bookings.filter { !$0.isCancelled && $0.endTime >= nowString() }
            .sorted { $0.startTime < $1.startTime }
    }

    private var past: [Booking] {
        bookings.filter { $0.isCancelled || $0.endTime < nowString() }
            .sorted { $0.startTime > $1.startTime }
    }

    private var shown: [Booking] { activeTab == 0 ? upcoming : past }

    var body: some View {
        ZStack {
            Color.fbBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Tabs
                HStack(spacing: 0) {
                    ForEach(["Предстоящие", "Прошедшие"].indices, id: \.self) { i in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) { activeTab = i }
                        } label: {
                            Text(["Предстоящие", "Прошедшие"][i])
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(activeTab == i ? Color.fbSurface : Color.clear)
                                .foregroundColor(activeTab == i ? .fbText : .fbTextMuted)
                                .cornerRadius(9)
                                .shadow(color: activeTab == i ? Color(hex: "172117").opacity(0.06) : .clear,
                                        radius: 3, x: 0, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(Color.fbSurfaceAlt)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 14)

                if isLoading && bookings.isEmpty {
                    ProgressView().tint(Color.fbPrimary).frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if shown.isEmpty {
                    VStack(spacing: 12) {
                        Text(activeTab == 0 ? "📅" : "🕐").font(.system(size: 40))
                        Text(activeTab == 0 ? "Нет предстоящих бронирований" : "Нет прошедших бронирований")
                            .font(.system(size: 15, weight: .semibold)).foregroundColor(.fbText)
                        Text("Выберите площадку и забронируйте время")
                            .font(.system(size: 13)).foregroundColor(.fbTextMuted)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            if let error = errorMessage {
                                ErrorBanner(message: error).padding(.horizontal, 16).padding(.bottom, 12)
                            }

                            // Section label
                            HStack {
                                Text(activeTab == 0 ? "АКТИВНЫЕ" : "ИСТОРИЯ")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.fbTextMuted).tracking(0.8)
                                Spacer()
                                Text("\(shown.count)")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.fbTextMuted)
                            }
                            .padding(.horizontal, 16).padding(.bottom, 8)

                            LazyVStack(spacing: 10) {
                                ForEach(shown) { booking in
                                    BookingCard(booking: booking) {
                                        Task { await cancel(booking.id) }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 24)
                        }
                    }
                    .refreshable { await load() }
                }
            }
        }
        .navigationTitle("Мои бронирования")
        .task { await load() }
    }

    private func nowString() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f.string(from: Date())
    }

    private func load() async {
        isLoading = true; errorMessage = nil
        do {
            bookings = try await APIClient.shared.fetchPage("/bookings/my")
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
            if let idx = bookings.firstIndex(where: { $0.id == id }) { bookings[idx] = updated }
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
        VStack(spacing: 0) {
            // Top
            HStack(alignment: .top) {
                // Date block
                VStack(spacing: 1) {
                    Text(monthLabel(booking.startTime))
                        .font(.system(size: 8, weight: .bold)).foregroundColor(.fbTextMuted)
                        .textCase(.uppercase).tracking(0.5)
                    Text(dayLabel(booking.startTime))
                        .font(.system(size: 18, weight: .bold)).foregroundColor(.fbText)
                }
                .frame(width: 44)
                .padding(.vertical, 6)
                .background(Color.fbSurface)
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.fbBorder, lineWidth: 1))
                .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(booking.fieldName)
                        .font(.system(size: 15, weight: .bold)).foregroundColor(.fbText).lineLimit(1)
                    Text(booking.username)
                        .font(.system(size: 12)).foregroundColor(.fbTextMuted)
                }
                Spacer()
                StatusBadge(status: booking.status)
            }
            .padding(.horizontal, 14).padding(.top, 12).padding(.bottom, 10)

            // Dashed divider
            Rectangle()
                .fill(Color.fbBorder)
                .frame(height: 1)
                .padding(.horizontal, 14)

            // Time row
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("НАЧАЛО").font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(.fbTextFaint).tracking(0.5)
                    Text(booking.startTime.toShortDateTime())
                        .font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(.fbText)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("КОНЕЦ").font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(.fbTextFaint).tracking(0.5)
                    Text(booking.endTime.toShortDateTime())
                        .font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(.fbText)
                }
                Spacer()
                Text("\(Int(booking.totalPrice)) ₽")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.fbPrimary)
            }
            .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 12)

            // Cancel button
            if !booking.isCancelled {
                Button("Отменить бронирование") { showAlert = true }
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.fbDangerSoft)
                    .foregroundColor(.fbDanger)
                    .overlay(Rectangle().fill(Color.fbBorder).frame(height: 1), alignment: .top)
            }
        }
        .background(Color.fbSurface)
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
        .cornerRadius(14)
        .shadow(color: Color(hex: "172117").opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(booking.isCancelled ? 0.6 : 1)
        .alert("Отменить бронирование?", isPresented: $showAlert) {
            Button("Отменить", role: .destructive) { onCancel() }
            Button("Назад", role: .cancel) {}
        } message: {
            Text("\(booking.fieldName)\n\(booking.startTime.toDisplayDateTime())")
        }
    }

    private func monthLabel(_ s: String) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let d = f.date(from: s) else { return "" }
        let out = DateFormatter(); out.dateFormat = "MMM"; out.locale = Locale(identifier: "ru_RU")
        return out.string(from: d)
    }

    private func dayLabel(_ s: String) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let d = f.date(from: s) else { return "" }
        let out = DateFormatter(); out.dateFormat = "d"
        return out.string(from: d)
    }
}
