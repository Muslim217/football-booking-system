import SwiftUI

struct OwnerDashboardView: View {
    @State private var fields: [Field] = []
    @State private var allBookings: [Booking] = []
    @State private var isLoading = false
    @State private var showFieldForm = false
    @State private var editingField: Field?
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private var activeCount: Int { fields.filter { $0.isActive }.count }
    private var bookingCount: Int { allBookings.filter { !$0.isCancelled }.count }

    var body: some View {
        List {
            // Stats row
            Section {
                HStack(spacing: 10) {
                    StatCard(label: "Полей",     value: "\(fields.count)",  color: .primary)
                    StatCard(label: "Активных",  value: "\(activeCount)",   color: .green)
                    StatCard(label: "Броней",    value: "\(bookingCount)",  color: .blue)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .padding(.vertical, 6)
            }

            // Alerts
            if let msg = errorMessage {
                Section { ErrorBanner(message: msg) }
            }
            if let msg = successMessage {
                Section { SuccessBanner(message: msg) }
            }

            // My fields
            Section {
                if fields.isEmpty && !isLoading {
                    Button {
                        editingField = nil
                        showFieldForm = true
                    } label: {
                        Label("Добавить первое поле", systemImage: "plus.circle.fill")
                    }
                    .foregroundColor(.green)
                } else {
                    ForEach(fields) { field in
                        FieldOwnerRow(
                            field: field,
                            onEdit: {
                                editingField = field
                                showFieldForm = true
                            },
                            onToggle: { Task { await toggle(field) } }
                        )
                    }
                }
            } header: {
                HStack {
                    Text("Мои поля")
                    Spacer()
                    Button {
                        editingField = nil
                        showFieldForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                }
            }

            // Bookings of my fields
            if !allBookings.isEmpty {
                Section("Бронирования") {
                    ForEach(allBookings.sorted { $0.startTime > $1.startTime }) { booking in
                        OwnerBookingRow(booking: booking)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Мои поля")
        .refreshable { await loadData() }
        .task { await loadData() }
        .sheet(isPresented: $showFieldForm, onDismiss: { Task { await loadData() } }) {
            FieldFormView(existing: editingField)
        }
    }

    // MARK: - Data loading

    private func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            fields = try await APIClient.shared.fetch("/fields/my")
            var bookings: [Booking] = []
            for f in fields {
                if let b: [Booking] = try? await APIClient.shared.fetch("/bookings/field/\(f.id)") {
                    bookings.append(contentsOf: b)
                }
            }
            allBookings = bookings
        } catch let e as APIError {
            errorMessage = e.errorDescription
        }
        isLoading = false
    }

    private func toggle(_ field: Field) async {
        errorMessage = nil
        do {
            if field.isActive {
                try await APIClient.shared.send("/fields/\(field.id)", method: "DELETE")
                flash(success: "Поле деактивировано")
            } else {
                try await APIClient.shared.send("/fields/\(field.id)/activate", method: "PUT")
                flash(success: "Поле активировано")
            }
            await loadData()
        } catch let e as APIError {
            errorMessage = e.errorDescription
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

// MARK: - Field Owner Row

private struct FieldOwnerRow: View {
    let field: Field
    let onEdit: () -> Void
    let onToggle: () -> Void

    @State private var showToggleAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(field.name).font(.subheadline.bold())
                    Text(field.address).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text(field.isActive ? "Активно" : "Неактивно")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(field.isActive ? Color.green.opacity(0.12) : Color.gray.opacity(0.12))
                    .foregroundColor(field.isActive ? .green : .gray)
                    .cornerRadius(6)
            }

            HStack(spacing: 6) {
                Text(field.formattedPrice).font(.caption).foregroundColor(.green)
                Text("·").foregroundColor(.secondary)
                FieldTypeBadge(fieldType: field.fieldType)
                Spacer()

                Button(action: onEdit) {
                    Label("Изменить", systemImage: "pencil")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered).tint(.blue).controlSize(.small)

                Button { showToggleAlert = true } label: {
                    Image(systemName: field.isActive ? "pause.circle" : "play.circle")
                }
                .buttonStyle(.bordered)
                .tint(field.isActive ? .orange : .green)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
        .alert(field.isActive ? "Деактивировать поле?" : "Активировать поле?",
               isPresented: $showToggleAlert) {
            Button(field.isActive ? "Деактивировать" : "Активировать",
                   role: field.isActive ? .destructive : .none) { onToggle() }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text(field.name)
        }
    }
}

// MARK: - Owner Booking Row

private struct OwnerBookingRow: View {
    let booking: Booking

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(booking.fieldName).font(.subheadline.bold())
                Spacer()
                StatusBadge(status: booking.status)
            }
            HStack(spacing: 4) {
                Image(systemName: "person.fill").font(.caption).foregroundColor(.secondary)
                Text(booking.username).font(.caption).foregroundColor(.secondary)
            }
            Text("\(booking.startTime.toShortDateTime()) — \(booking.endTime.toShortDateTime())")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(Int(booking.totalPrice)) ₽")
                .font(.caption.bold())
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
        .opacity(booking.isCancelled ? 0.5 : 1)
    }
}
