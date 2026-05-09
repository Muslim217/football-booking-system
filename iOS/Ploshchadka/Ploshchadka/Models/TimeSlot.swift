import Foundation

struct TimeSlot: Codable, Identifiable {
    let startTime: String   // "08:00:00"
    let endTime: String     // "09:00:00"
    let available: Bool
    let price: Double

    var id: String { startTime }

    /// "08:00:00" → "08:00"
    var startLabel: String { String(startTime.prefix(5)) }
    var endLabel: String   { String(endTime.prefix(5)) }
}
