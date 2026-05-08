import Foundation

struct Field: Codable, Identifiable {
    let id: Int64
    let name: String
    let address: String
    let fieldType: String
    let pricePerHour: Double
    let description: String?
    let isActive: Bool
    let ownerUsername: String?
    let createdAt: String?

    var isIndoor: Bool { fieldType == "INDOOR" }

    var fieldTypeLabel: String { isIndoor ? "Крытое" : "Открытое" }

    var formattedPrice: String { "\(Int(pricePerHour)) ₽/час" }
}
