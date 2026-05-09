import SwiftUI

struct FieldDetailView: View {
    let field: Field

    @Environment(AuthStore.self) var authStore
    @State private var bookings: [Booking] = []
    @State private var showBookingForm = false
    @State private var selectedDate = Date()

    private let weekDays = (0..<7).compactMap {
        Calendar.current.date(byAdding: .day, value: $0, to: Calendar.current.startOfDay(for: Date()))
    }
    private var activeBookings: [Booking] { bookings.filter { !$0.isCancelled } }

    var body: some View {
        ZStack {
            Color.fbBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Full-width pitch photo
                    ZStack(alignment: .topLeading) {
                        ZStack {
                            LinearGradient(
                                colors: [Color(hex: "2C8341"), Color(hex: "1B6B2E"), Color(hex: "145322")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                            GeometryReader { _ in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 2).padding(14)
                                    Rectangle()
                                        .fill(Color.white.opacity(0.18))
                                        .frame(width: 2).frame(maxHeight: .infinity).padding(.vertical, 14)
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 2)
                                        .frame(width: 56, height: 56)
                                }
                            }
                        }
                        .frame(height: 168)
                        HStack {
                            Spacer()
                            FieldTypeBadge(fieldType: field.fieldType).padding(12)
                        }
                    }

                    // Main info card
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(field.name).font(.system(size: 20, weight: .bold)).foregroundColor(.fbText)
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill").font(.system(size: 11)).foregroundColor(.fbTextFaint)
                                Text(field.address).font(.system(size: 13)).foregroundColor(.fbTextMuted)
                            }
                        }
                        .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 12)

                        if let desc = field.description, !desc.isEmpty {
                            Text(desc).font(.system(size: 14)).foregroundColor(.fbTextMuted).lineSpacing(3)
                                .padding(.horizontal, 16).padding(.bottom, 12)
                        }

                        // Inactive badge
                        if !field.isActive {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.fbWarning)
                                Text("Площадка временно недоступна")
                                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.fbWarning)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.fbWarningSoft)
                            .cornerRadius(10)
                            .padding(.horizontal, 16).padding(.bottom, 12)
                        }

                        Divider().background(Color.fbBorder)

                        // Price + CTA
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("СТОИМОСТЬ")
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.fbTextFaint).tracking(0.8)
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("\(Int(field.pricePerHour)) ₽")
                                        .font(.system(size: 28, weight: .bold)).foregroundColor(.fbText)
                                    Text("/ час").font(.system(size: 13)).foregroundColor(.fbTextMuted)
                                }
                            }
                            Spacer()
                            if authStore.isLoggedIn && field.isActive {
                                Button { showBookingForm = true } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar.badge.plus")
                                        Text("Забронировать").fontWeight(.bold)
                                    }
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 16).padding(.vertical, 12)
                                    .background(Color.fbPrimary).foregroundColor(.white).cornerRadius(12)
                                }
                            }
                        }
                        .padding(16)
                    }
                    .background(Color.fbSurface).cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.fbBorder, lineWidth: 1))
                    .shadow(color: Color(hex: "172117").opacity(0.06), radius: 8, x: 0, y: 2)
                    .padding(16)

                    // Schedule section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Расписание")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(.fbText).padding(.bottom, 12)

                        // Date strip
                        HStack(spacing: 6) {
                            ForEach(weekDays, id: \.self) { date in
                                Button { selectedDate = date } label: {
                                    VStack(spacing: 2) {
                                        Text(date.formatted(.dateTime.weekday(.abbreviated)).prefix(2).uppercased())
                                            .font(.system(size: 9, weight: .semibold))
                                        Text(date.formatted(.dateTime.day()))
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                                    .background(Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                                ? Color.fbPrimary : Color.fbSurface)
                                    .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                                     ? .white : .fbText)
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                                      ? Color.fbPrimary : Color.fbBorder, lineWidth: 1))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 14)

                        // Busy slots for selected day
                        let busyOnDay = activeBookings.filter { booking in
                            guard let startDate = parseDate(booking.startTime) else { return false }
                            return Calendar.current.isDate(startDate, inSameDayAs: selectedDate)
                        }

                        if busyOnDay.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.fbPrimary)
                                Text("Свободно — нет бронирований на этот день")
                                    .font(.system(size: 13)).foregroundColor(.fbTextMuted)
                            }
                            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.fbPrimarySoft).cornerRadius(10)
                        } else {
                            VStack(spacing: 6) {
                                ForEach(busyOnDay) { booking in
                                    HStack(spacing: 8) {
                                        Image(systemName: "clock.fill").font(.system(size: 10)).foregroundColor(.fbWarning)
                                        Text("\(booking.startTime.toShortDateTime()) — \(booking.endTime.toShortDateTime())")
                                            .font(.system(size: 12, design: .monospaced)).foregroundColor(.fbText)
                                        Spacer()
                                        Text("Занято").font(.system(size: 11, weight: .semibold))
                                            .padding(.horizontal, 8).padding(.vertical, 3)
                                            .background(Color.fbWarningSoft).foregroundColor(.fbWarning).cornerRadius(6)
                                    }
                                    .padding(.horizontal, 12).padding(.vertical, 9)
                                    .background(Color.fbSurface)
                                    .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(Color.fbBorder, lineWidth: 1))
                                    .cornerRadius(9)
                                }
                            }
                        }
                    }
                    .padding(16).background(Color.fbSurface).cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.fbBorder, lineWidth: 1))
                    .shadow(color: Color(hex: "172117").opacity(0.05), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16).padding(.bottom, 16)

                    // Login hint
                    if !authStore.isLoggedIn {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle").foregroundColor(.fbInfo)
                            Text("Войдите, чтобы забронировать поле")
                                .font(.system(size: 13)).foregroundColor(.fbTextMuted)
                        }
                        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.fbInfoSoft)
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.fbInfo.opacity(0.2), lineWidth: 1))
                        .cornerRadius(12)
                        .padding(.horizontal, 16).padding(.bottom, 16)
                    }

                    // Bottom CTA — only if active + logged in
                    if authStore.isLoggedIn && field.isActive {
                        Button { showBookingForm = true } label: {
                            Text("Забронировать поле")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .background(Color.fbPrimary).foregroundColor(.white).cornerRadius(14)
                        }
                        .padding(.horizontal, 16).padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationTitle(field.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBookingForm, onDismiss: { Task { await loadBookings() } }) {
            BookingFormView(field: field)
        }
        .task { await loadBookings() }
    }

    private func loadBookings() async {
        guard let b: [Booking] = try? await APIClient.shared.fetchPage("/bookings/field/\(field.id)") else { return }
        bookings = b
    }

    private func parseDate(_ str: String) -> Date? {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f.date(from: str)
    }
}
