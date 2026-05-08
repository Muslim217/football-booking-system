import Foundation

struct Field: Codable, Identifiable {
    let id: Int64
    let name: String
    let address: String
    let city: String?
    let fieldType: String
    let pricePerHour: Double
    let description: String?
    let photoUrl: String?
    let isActive: Bool
    let ownerUsername: String?
    let createdAt: String?

    // Decode pricePerHour from either Double or String (backend uses BigDecimal)
    enum CodingKeys: String, CodingKey {
        case id, name, address, city, fieldType, pricePerHour
        case description, photoUrl, isActive, ownerUsername, createdAt
    }

    var fieldTypeLabel: String {
        switch fieldType {
        case "FOOTBALL":   return "Футбол"
        case "BASKETBALL": return "Баскетбол"
        case "VOLLEYBALL": return "Волейбол"
        case "TENNIS":     return "Теннис"
        case "PADEL":      return "Падел"
        case "HOCKEY":     return "Хоккей"
        case "INDOOR":     return "Крытое"
        case "OUTDOOR":    return "Открытое"
        default:           return fieldType
        }
    }

    var isIndoor: Bool { fieldType == "INDOOR" }

    var formattedPrice: String { "\(Int(pricePerHour)) ₽/час" }
}
