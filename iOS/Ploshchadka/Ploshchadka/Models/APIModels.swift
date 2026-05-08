import Foundation

// MARK: - Auth

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
    let role: String
}

struct AuthResponse: Codable {
    let token: String
    let username: String
    let role: String
}

// MARK: - Field

struct FieldRequest: Codable {
    let name: String
    let address: String
    let fieldType: String
    let pricePerHour: Double
    let description: String
}

// MARK: - Booking

struct BookingRequest: Codable {
    let fieldId: Int64
    let startTime: String
    let endTime: String
}

// MARK: - Generic

struct MessageResponse: Codable {
    let message: String?
}
