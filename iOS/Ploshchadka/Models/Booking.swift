import Foundation

struct Booking: Codable, Identifiable {
    let id: Int64
    let username: String
    let fieldId: Int64
    let fieldName: String
    let startTime: String
    let endTime: String
    let totalPrice: Double
    let status: String
    let createdAt: String?

    var isCancelled: Bool { status == "CANCELLED" }

    var statusLabel: String {
        switch status {
        case "CONFIRMED": return "Подтверждено"
        case "PENDING":   return "Ожидание"
        case "CANCELLED": return "Отменено"
        default:          return status
        }
    }
}
