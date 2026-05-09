import SwiftUI

struct OwnerDashboardView: View {
    @State private var fields: [Field] = []
    @State private var allBookings: [Booking] = []
    @State private var isLoading = false
    @State private var showFieldForm = false
    @State private var editingField: Field?
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private var activeCount: Int  { fields.filter { $0.isActive }.count }
    private var bookingCount: Int { allBookings.filter { !$0.isCancelled }.count }

    var body: some View {
        ZStack {
            Color.fbBg.ignoresSafeArea()

            if isLoading && fields.isEmpty {
                ProgressView().tint(Color.fbPrimary)
            } else if let error = errorMessage, fields.isEmpty {
                // Error state with retry
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash").font(.system(size: 40)).foregroundColor(.fbTextFaint)
                    Text(error).font(.system(size: 15)).foregroundColor(.fbTextMuted).multilineTextAlignment(.center)
                    Button("Повторить") { Task { await loadData() } }
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 18).padding(.vertical, 9)
                        .background(Color.fbPrimary).foregroundColor(.white).cornerRadius(8)
                }
                .padding(24)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Stats
                        HStack(spacing: 12) {
                            StatCard(label: "Всего полей",  value: "\(fields.count)",  color: .primary)
                            StatCard(label: "Активных",     value: "\(activeCount)",   color: .fbPrimary)
                            StatCard(label: "Бронирований", value: "\(bookingCount)",  color: .fbInfo)
                        }

                        if let msg = successMessage { SuccessBanner(message: msg) }
                        if let msg = errorMessage   { ErrorBanner(message: msg) }

                        // My fields section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Мои поля")
                                    .font(.system(size: 17, weight: .bold)).foregroundColor(.fbText)
                                Spacer()
                                Button {
                                    editingField = nil; showFieldForm = true
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "plus")
                                        Text("Добавить")
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(Color.fbPrimary).foregroundColor(.white).cornerRadius(8)
                                }
                            }

                            if fields.isEmpty {
                                VStack(spacing: 12) {
                                    Text("🏟️").font(.system(size: 36))
                                    Text("У вас ещё нет площадок")
                                        .font(.system(size: 15)).foregroundColor(.fbTextMuted)
                                    Button {
                                        editingField = nil; showFieldForm = true
                                    } label: {
                                        Label("Добавить первое поле", systemImage: "plus.circle.fill")
                                            .font(.system(size: 14, weight: .semibold)).foregroundColor(.fbPrimary)
                                    }
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 32)
                                .background(Color.fbSurface)
                                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
                                .cornerRadius(14)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(fields) { field in
                                        OwnerFieldRow(
                                            field: field,
                                            onEdit: { editingField = field; showFieldForm = true },
                                            onToggle: { Task { await toggle(field) } }
                                        )
                                    }
                                }
                            }
                        }

                        // Bookings section
                        if !allBookings.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Бронирования")
                                        .font(.system(size: 17, weight: .bold)).foregroundColor(.fbText)
                                    Spacer()
                                    Text("\(bookingCount) активных")
                                        .font(.system(size: 12)).foregroundColor(.fbTextMuted)
                                }
                                VStack(spacing: 10) {
                                    ForEach(allBookings.sorted { $0.startTime > $1.startTime }) { booking in
                                        OwnerBookingRow(booking: booking)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                .refreshable { await loadData() }
            }
        }
        .navigationTitle("Мои поля")
        .task { await loadData() }
        .sheet(isPresented: $showFieldForm, onDismiss: { Task { await loadData() } }) {
            FieldFormView(existing: editingField)
        }
    }

    private func loadData() async {
        isLoading = true; errorMessage = nil
        do {
            async let fieldsTask: [Field]   = APIClient.shared.fetchPage("/fields/my")
            async let bookingsTask: [Booking] = APIClient.shared.fetchPage("/bookings/owner")
            fields      = try await fieldsTask
            allBookings = try await bookingsTask
        } catch let e as APIError {
            errorMessage = e.errorDescription
        } catch {
            errorMessage = "Ошибка загрузки"
        }
        isLoading = false
    }

    private func toggle(_ field: Field) async {
        errorMessage = nil
        do {
            if field.isActive {
                try await APIClient.shared.send("/fields/\(field.id)/deactivate", method: "PUT")
                flash(success: "Поле деактивировано")
            } else {
                try await APIClient.shared.send("/fields/\(field.id)/activate", method: "PUT")
                flash(success: "Поле активировано")
            }
            await loadData()
        } catch let e as APIError {
            errorMessage = e.errorDescription
        } catch {
            errorMessage = "Ошибка соединения"
        }
    }

    private func flash(success msg: String) {
        successMessage = msg
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            successMessage = nil
        }
    }
}

// MARK: - Owner Field Row

private struct OwnerFieldRow: View {
    let field: Field
    let onEdit: () -> Void
    let onToggle: () -> Void
    @State private var showToggleAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(field.name).font(.system(size: 15, weight: .bold)).foregroundColor(.fbText)
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill").font(.system(size: 11)).foregroundColor(.fbTextFaint)
                        Text(field.address).font(.system(size: 13)).foregroundColor(.fbTextMuted)
                    }
                }
                Spacer()
                HStack(spacing: 5) {
                    Circle().fill(field.isActive ? Color.fbPrimary : Color.fbTextFaint).frame(width: 6, height: 6)
                    Text(field.isActive ? "Активно" : "Неактивно")
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(field.isActive ? Color.fbPrimarySoft : Color.fbSurfaceAlt)
                .foregroundColor(field.isActive ? .fbPrimary : .fbTextMuted)
                .clipShape(Capsule())
            }

            HStack(spacing: 8) {
                Text(field.formattedPrice)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced)).foregroundColor(.fbText)
                FieldTypeBadge(fieldType: field.fieldType)
                Spacer()
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil"); Text("Изменить")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.fbInfoSoft).foregroundColor(.fbInfo)
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.fbInfo.opacity(0.3), lineWidth: 1))
                    .cornerRadius(8)
                }
                Button { showToggleAlert = true } label: {
                    Image(systemName: field.isActive ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(field.isActive ? .fbWarning : .fbPrimary)
                }
            }
        }
        .padding(16)
        .background(Color.fbSurface)
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
        .cornerRadius(14)
        .shadow(color: Color(hex: "172117").opacity(0.05), radius: 6, x: 0, y: 2)
        .alert(field.isActive ? "Деактивировать поле?" : "Активировать поле?",
               isPresented: $showToggleAlert) {
            Button(field.isActive ? "Деактивировать" : "Активировать",
                   role: field.isActive ? .destructive : .none) { onToggle() }
            Button("Отмена", role: .cancel) {}
        } message: { Text(field.name) }
    }
}

// MARK: - Owner Booking Row

private struct OwnerBookingRow: View {
    let booking: Booking

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(booking.fieldName).font(.system(size: 14, weight: .bold)).foregroundColor(.fbText)
                Spacer()
                StatusBadge(status: booking.status)
            }
            HStack(spacing: 5) {
                Image(systemName: "person.fill").font(.system(size: 11)).foregroundColor(.fbTextFaint)
                Text(booking.username).font(.system(size: 13)).foregroundColor(.fbTextMuted)
            }
            Text("\(booking.startTime.toShortDateTime()) — \(booking.endTime.toShortDateTime())")
                .font(.system(size: 12, design: .monospaced)).foregroundColor(.fbTextMuted)
            Divider().background(Color.fbBorder)
            Text("\(Int(booking.totalPrice)) ₽")
                .font(.system(size: 15, weight: .bold, design: .monospaced)).foregroundColor(.fbText)
        }
        .padding(16)
        .background(Color.fbSurface)
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
        .cornerRadius(14)
        .shadow(color: Color(hex: "172117").opacity(0.05), radius: 6, x: 0, y: 2)
        .opacity(booking.isCancelled ? 0.5 : 1)
    }
}
