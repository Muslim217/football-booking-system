import SwiftUI

struct FieldDetailView: View {
    let field: Field

    @Environment(AuthStore.self) var authStore
    @State private var bookings: [Booking] = []
    @State private var showBookingForm = false

    private var activeBookings: [Booking] {
        bookings.filter { !$0.isCancelled }
    }

    var body: some View {
        ZStack {
            Color.fbBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Pitch + header card
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            FieldPitchView()
                            FieldTypeBadge(fieldType: field.fieldType).padding(12)
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(field.name)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.fbText)
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.fbTextFaint)
                                    Text(field.address)
                                        .font(.system(size: 14))
                                        .foregroundColor(.fbTextMuted)
                                }
                            }

                            if let owner = field.ownerUsername {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.fbTextFaint)
                                    Text(owner)
                                        .font(.system(size: 13))
                                        .foregroundColor(.fbTextMuted)
                                }
                            }

                            if let desc = field.description, !desc.isEmpty {
                                Text(desc)
                                    .font(.system(size: 14))
                                    .foregroundColor(.fbTextMuted)
                                    .lineSpacing(3)
                            }

                            Divider().background(Color.fbBorder)

                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Стоимость")
                                        .font(.system(size: 12))
                                        .foregroundColor(.fbTextMuted)
                                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                                        Text("\(Int(field.pricePerHour)) ₽")
                                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                                            .foregroundColor(.fbText)
                                        Text("/ час")
                                            .font(.system(size: 14))
                                            .foregroundColor(.fbTextMuted)
                                    }
                                }
                                Spacer()
                                if authStore.isLoggedIn {
                                    Button {
                                        showBookingForm = true
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "calendar.badge.plus")
                                            Text("Забронировать")
                                                .fontWeight(.semibold)
                                        }
                                        .font(.system(size: 14))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 11)
                                        .background(Color.fbPrimary)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                    .background(Color.fbSurface)
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.fbBorder, lineWidth: 1))
                    .cornerRadius(20)
                    .shadow(color: Color(hex: "172117").opacity(0.06), radius: 8, x: 0, y: 2)

                    // Busy times card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.badge.exclamationmark")
                                .foregroundColor(.fbPrimary)
                            Text("Занятое время")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.fbText)
                        }

                        if activeBookings.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.fbPrimary)
                                Text("Свободно — нет активных бронирований")
                                    .font(.system(size: 14))
                                    .foregroundColor(.fbTextMuted)
                            }
                        } else {
                            VStack(spacing: 6) {
                                ForEach(activeBookings) { booking in
                                    HStack(spacing: 8) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(.fbWarning)
                                        Text("\(booking.startTime.toShortDateTime()) — \(booking.endTime.toShortDateTime())")
                                            .font(.system(size: 13, design: .monospaced))
                                            .foregroundColor(.fbText)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.fbWarningSoft)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.fbSurface)
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.fbBorder, lineWidth: 1))
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "172117").opacity(0.06), radius: 8, x: 0, y: 2)

                    if !authStore.isLoggedIn {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.fbInfo)
                            Text("Войдите в аккаунт, чтобы забронировать поле")
                                .font(.system(size: 14))
                                .foregroundColor(.fbTextMuted)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.fbInfoSoft)
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.fbInfo.opacity(0.25), lineWidth: 1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .padding(.bottom, 16)
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
        guard let b: [Booking] = try? await APIClient.shared.fetch("/bookings/field/\(field.id)") else { return }
        bookings = b
    }
}
