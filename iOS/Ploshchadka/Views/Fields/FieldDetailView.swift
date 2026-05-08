import SwiftUI

struct FieldDetailView: View {
    let field: Field

    @EnvironmentObject var authStore: AuthStore
    @State private var bookings: [Booking] = []
    @State private var showBookingForm = false

    private var activeBookings: [Booking] {
        bookings.filter { !$0.isCancelled }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Main info card
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(field.name)
                                .font(.title2.bold())
                            Label(field.address, systemImage: "location.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        FieldTypeBadge(fieldType: field.fieldType)
                    }

                    if let owner = field.ownerUsername {
                        Label(owner, systemImage: "person.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let desc = field.description, !desc.isEmpty {
                        Text(desc)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Стоимость")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(Int(field.pricePerHour)) ₽")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.green)
                                Text("/ час")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if authStore.isLoggedIn {
                            Button {
                                showBookingForm = true
                            } label: {
                                Label("Забронировать", systemImage: "calendar.badge.plus")
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

                // Busy times card
                VStack(alignment: .leading, spacing: 12) {
                    Label("Занятое время", systemImage: "clock.badge.exclamationmark")
                        .font(.headline)

                    if activeBookings.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Свободно — нет активных бронирований")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        ForEach(activeBookings) { booking in
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text("\(booking.startTime.toShortDateTime()) — \(booking.endTime.toShortDateTime())")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color.orange.opacity(0.07))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

                if !authStore.isLoggedIn {
                    Text("Войдите в аккаунт, чтобы забронировать поле")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(field.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBookingForm, onDismiss: {
            Task { await loadBookings() }
        }) {
            BookingFormView(field: field)
        }
        .task { await loadBookings() }
    }

    private func loadBookings() async {
        guard let b: [Booking] = try? await APIClient.shared.fetch("/bookings/field/\(field.id)") else { return }
        bookings = b
    }
}
