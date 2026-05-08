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

// Backend returns accessToken (not token)
struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let username: String
    let role: String

    // Convenience alias
    var token: String { accessToken }
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

// MARK: - Pagination wrapper (Spring Page<T>)

struct PageResponse<T: Decodable>: Decodable {
    let content: [T]
    let totalElements: Int
    let totalPages: Int
    let number: Int      // current page (0-based)
    let size: Int
    let last: Bool

    var isLastPage: Bool { last }
}
