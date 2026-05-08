import Foundation
import SwiftUI

@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var token: String?
    @Published private(set) var username: String?
    @Published private(set) var role: String?

    var isLoggedIn: Bool { token != nil }
    var isAdmin:    Bool { role == "ADMIN" }
    var isOwner:    Bool { role == "OWNER" }
    var isUser:     Bool { role == "USER" }

    private let defaults = UserDefaults.standard

    init() {
        token    = defaults.string(forKey: "jwt_token")
        username = defaults.string(forKey: "username")
        role     = defaults.string(forKey: "role")
        APIClient.shared.token = token
    }

    func saveAuth(_ response: AuthResponse) {
        token    = response.token
        username = response.username
        role     = response.role

        APIClient.shared.token = response.token

        defaults.set(response.token,    forKey: "jwt_token")
        defaults.set(response.username, forKey: "username")
        defaults.set(response.role,     forKey: "role")
    }

    func logout() {
        token    = nil
        username = nil
        role     = nil

        APIClient.shared.token = nil

        defaults.removeObject(forKey: "jwt_token")
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "role")
    }
}
