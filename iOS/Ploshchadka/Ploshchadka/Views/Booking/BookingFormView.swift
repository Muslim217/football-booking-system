import SwiftUI

struct BookingFormView: View {
    let field: Field

    @Environment(\.dismiss) var dismiss

    // Date selection
    private let weekDays: [Date] = (0..<14).compactMap {
        Calendar.current.date(byAdding: .day, value: $0, to: Calendar.current.startOfDay(for: Date()))
    }
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    // Slots
    @State private var slots: [TimeSlot] = []
    @State private var slotsLoading = false

    // Selection: user taps first slot = start, taps second = end
    @State private var startSlot: TimeSlot?
    @State private var endSlot: TimeSlot?

    // Booking
    @State private var isBooking = false
    @State private var errorMessage: String?
    @State private var didBook = false

    // MARK: - Computed

    private var selectedSlots: [TimeSlot] {
        guard let s = startSlot else { return [] }
        guard let e = endSlot else { return [s] }
        let startIdx = slots.firstIndex(where: { $0.id == s.id }) ?? 0
        let endIdx   = slots.firstIndex(where: { $0.id == e.id }) ?? 0
        let range = min(startIdx, endIdx)...max(startIdx, endIdx)
        return Array(slots[range])
    }

    private var totalPrice: Double {
        Double(selectedSlots.count) * field.pricePerHour
    }

    private var canBook: Bool {
        startSlot != nil && endSlot != nil && selectedSlots.allSatisfy { $0.available }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fbBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        // ── Field info ───────────────────────────
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.fbPrimary.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "sportscourt.fill")
                                    .foregroundColor(.fbPrimary).font(.system(size: 20))
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(field.name)
                                    .font(.system(size: 15, weight: .bold)).foregroundColor(.fbText)
                                Text(field.address)
                                    .font(.system(size: 13)).foregroundColor(.fbTextMuted)
                            }
                            Spacer()
                            FieldTypeBadge(fieldType: field.fieldType)
                        }
                        .padding(16)
                        .background(Color.fbSurface)
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
                        .cornerRadius(14)

                        // ── Date strip ───────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ВЫБЕРИТЕ ДЕНЬ")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(.fbTextMuted).tracking(0.8)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(weekDays, id: \.self) { date in
                                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                        Button {
                                            selectedDate = date
                                            startSlot = nil
                                            endSlot = nil
                                            Task { await loadSlots() }
                                        } label: {
                                            VStack(spacing: 2) {
                                                Text(date.formatted(.dateTime.weekday(.abbreviated)).prefix(2).uppercased())
                                                    .font(.system(size: 9, weight: .semibold))
                                                Text(date.formatted(.dateTime.day()))
                                                    .font(.system(size: 15, weight: .bold))
                                            }
                                            .frame(width: 44)
                                            .padding(.vertical, 8)
                                            .background(isSelected ? Color.fbPrimary : Color.fbSurface)
                                            .foregroundColor(isSelected ? .white : .fbText)
                                            .overlay(RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(isSelected ? Color.fbPrimary : Color.fbBorder, lineWidth: 1))
                                            .cornerRadius(10)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.fbSurface)
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
                        .cornerRadius(14)

                        // ── Time slots ───────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("ДОСТУПНЫЕ СЛОТЫ")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.fbTextMuted).tracking(0.8)
                                Spacer()
                                if startSlot != nil {
                                    Button("Сбросить") {
                                        startSlot = nil; endSlot = nil
                                    }
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.fbDanger)
                                }
                            }

                            if slotsLoading {
                                HStack { Spacer(); ProgressView().tint(Color.fbPrimary); Spacer() }
                                    .padding(.vertical, 20)
                            } else if slots.isEmpty {
                                Text("Нет данных о расписании")
                                    .font(.system(size: 14)).foregroundColor(.fbTextMuted)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 16)
                            } else {
                                // Legend
                                HStack(spacing: 16) {
                                    LegendItem(color: .fbPrimary, label: "Выбрано")
                                    LegendItem(color: Color.fbSurfaceAlt, label: "Свободно", border: true)
                                    LegendItem(color: Color(hex: "F5E6E6"), label: "Занято")
                                }
                                .padding(.bottom, 4)

                                // Grid: 3 columns
                                let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(slots) { slot in
                                        SlotCell(
                                            slot: slot,
                                            isSelected: selectedSlots.contains(where: { $0.id == slot.id }),
                                            isStart: startSlot?.id == slot.id,
                                            isEnd: endSlot?.id == slot.id
                                        ) {
                                            handleTap(slot)
                                        }
                                    }
                                }
                            }

                            // Selection hint
                            if startSlot == nil {
                                HStack(spacing: 6) {
                                    Image(systemName: "hand.tap.fill").foregroundColor(.fbInfo)
                                    Text("Нажмите на начальный слот")
                                        .font(.system(size: 13)).foregroundColor(.fbTextMuted)
                                }
                                .padding(10)
                                .background(Color.fbInfoSoft)
                                .cornerRadius(10)
                            } else if endSlot == nil {
                                HStack(spacing: 6) {
                                    Image(systemName: "hand.tap.fill").foregroundColor(.fbPrimary)
                                    Text("Теперь выберите конечный слот")
                                        .font(.system(size: 13)).foregroundColor(.fbTextMuted)
                                }
                                .padding(10)
                                .background(Color.fbPrimarySoft)
                                .cornerRadius(10)
                            }
                        }
                        .padding(16)
                        .background(Color.fbSurface)
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbBorder, lineWidth: 1))
                        .cornerRadius(14)

                        // ── Price summary ────────────────────────
                        if canBook {
                            VStack(spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("ИТОГО")
                                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.fbTextMuted).tracking(0.8)
                                        Text("\(Int(totalPrice)) ₽")
                                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                                            .foregroundColor(.fbText)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("\(selectedSlots.count) ч × \(Int(field.pricePerHour)) ₽")
                                            .font(.system(size: 13)).foregroundColor(.fbTextMuted)
                                        if let s = startSlot, let e = endSlot {
                                            Text("\(s.startLabel) — \(e.endLabel)")
                                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                                .foregroundColor(.fbText)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.fbPrimarySoft)
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.fbPrimary.opacity(0.3), lineWidth: 1))
                            .cornerRadius(14)
                        }

                        if let error = errorMessage { ErrorBanner(message: error) }
                        if didBook { SuccessBanner(message: "Бронирование создано!") }

                        // ── Confirm button ───────────────────────
                        Button {
                            Task { await book() }
                        } label: {
                            HStack(spacing: 8) {
                                if isBooking { ProgressView().tint(.white).scaleEffect(0.85) }
                                Image(systemName: "checkmark.circle.fill")
                                Text("Подтвердить бронирование")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(canBook ? Color.fbPrimary : Color.fbBorder)
                            .foregroundColor(canBook ? .white : .fbTextMuted)
                            .cornerRadius(10)
                        }
                        .disabled(isBooking || !canBook)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Забронировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }.foregroundColor(.fbPrimary)
                }
            }
            .task { await loadSlots() }
        }
    }

    // MARK: - Actions

    private func handleTap(_ slot: TimeSlot) {
        guard slot.available else { return }

        if startSlot == nil {
            // First tap — set start
            startSlot = slot
            endSlot = nil
        } else if endSlot == nil {
            // Second tap — set end (can be before start, we swap)
            if slot.id == startSlot?.id {
                // Tapped same slot — deselect
                startSlot = nil
            } else {
                endSlot = slot
                // Make sure start < end
                let startIdx = slots.firstIndex(where: { $0.id == startSlot?.id }) ?? 0
                let endIdx   = slots.firstIndex(where: { $0.id == slot.id }) ?? 0
                if endIdx < startIdx {
                    let tmp = startSlot
                    startSlot = endSlot
                    endSlot = tmp
                }
                // Check all selected slots are available
                if !selectedSlots.allSatisfy({ $0.available }) {
                    errorMessage = "В выбранном диапазоне есть занятые слоты"
                    endSlot = nil
                } else {
                    errorMessage = nil
                }
            }
        } else {
            // Third tap — reset and start over
            startSlot = slot
            endSlot = nil
            errorMessage = nil
        }
    }

    private func loadSlots() async {
        slotsLoading = true
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let dateStr = fmt.string(from: selectedDate)
        do {
            let result: [TimeSlot] = try await APIClient.shared.fetch(
                "/fields/\(field.id)/schedule?date=\(dateStr)"
            )
            slots = result
        } catch {
            slots = []
            errorMessage = "Не удалось загрузить расписание"
        }
        slotsLoading = false
    }

    private func book() async {
        guard let start = startSlot, let end = endSlot else { return }
        isBooking = true; errorMessage = nil

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let dateStr = fmt.string(from: selectedDate)

        let startISO = "\(dateStr)T\(start.startTime)"
        let endISO   = "\(dateStr)T\(end.endTime)"

        do {
            let _: Booking = try await APIClient.shared.fetch(
                "/bookings", method: "POST",
                body: BookingRequest(fieldId: field.id, startTime: startISO, endTime: endISO)
            )
            didBook = true
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            dismiss()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Ошибка соединения"
        }
        isBooking = false
    }
}

// MARK: - Slot Cell

private struct SlotCell: View {
    let slot: TimeSlot
    let isSelected: Bool
    let isStart: Bool
    let isEnd: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                Text(slot.startLabel)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                Text(slot.endLabel)
                    .font(.system(size: 11, design: .monospaced))
                    .opacity(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(background)
            .foregroundColor(foreground)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(border, lineWidth: isStart || isEnd ? 2 : 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(!slot.available)
    }

    private var background: Color {
        if !slot.available { return Color(hex: "F5E6E6") }
        if isSelected      { return Color.fbPrimary }
        return Color.fbSurfaceAlt
    }

    private var foreground: Color {
        if !slot.available { return Color(hex: "B83A3A").opacity(0.6) }
        if isSelected      { return .white }
        return .fbText
    }

    private var border: Color {
        if !slot.available { return Color(hex: "B83A3A").opacity(0.2) }
        if isSelected      { return Color.fbPrimary }
        return Color.fbBorder
    }
}

// MARK: - Legend Item

private struct LegendItem: View {
    let color: Color
    let label: String
    var border: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .overlay(
                    border ? RoundedRectangle(cornerRadius: 4).strokeBorder(Color.fbBorder, lineWidth: 1) : nil
                )
                .frame(width: 14, height: 14)
            Text(label)
                .font(.system(size: 11)).foregroundColor(.fbTextMuted)
        }
    }
}
