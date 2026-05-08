import Foundation

struct Booking: Codable, Identifiable {
    let id: Int64
    let username: String
    let fieldId: Int64
    let fieldName: String
    let fieldAddress: String?
    let startTime: String
    let endTime: String
    let totalPrice: Double
    let status: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, username, fieldId, fieldName, fieldAddress
        case startTime, endTime, totalPrice, status, createdAt
    }

    var isCancelled: Bool { status == "CANCELLED" }

    var statusLabel: String {
        switch status {
        case "CONFIRMED": return "Подтверждено"
        case "PENDING":   return "Ожидание"
        case "COMPLETED": return "Завершено"
        case "CANCELLED": return "Отменено"
        default:          return status
        }
    }
}

// MARK: - String helpers for date display

extension String {
    /// "2024-01-15T10:00:00" → "10:00, 15 янв"
    func toShortDateTime() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = f.date(from: self) else { return self }
        let out = DateFormatter()
        out.dateFormat = "HH:mm"
        return out.string(from: date)
    }

    /// "2024-01-15T10:00:00" → "15 января, 10:00"
    func toDisplayDateTime() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = f.date(from: self) else { return self }
        let out = DateFormatter()
        out.dateFormat = "d MMMM, HH:mm"
        out.locale = Locale(identifier: "ru_RU")
        return out.string(from: date)
    }
}
