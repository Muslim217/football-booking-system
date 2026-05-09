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

