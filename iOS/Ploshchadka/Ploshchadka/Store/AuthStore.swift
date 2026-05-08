import Foundation
import Observation

@Observable
final class AuthStore {
    var token: String?
    var username: String?
    var role: String?

    var isLoggedIn: Bool { token != nil }
    var isAdmin:    Bool { role == "ADMIN" }
    var isOwner:    Bool { role == "OWNER" }
    var isUser:     Bool { role == "USER" }

    init() {
        token    = UserDefaults.standard.string(forKey: "jwt_token")
        username = UserDefaults.standard.string(forKey: "username")
        role     = UserDefaults.standard.string(forKey: "role")
        APIClient.shared.token = token
    }

    func saveAuth(_ response: AuthResponse) {
        token    = response.accessToken
        username = response.username
        role     = response.role
        APIClient.shared.token = response.accessToken
        UserDefaults.standard.set(response.accessToken, forKey: "jwt_token")
        UserDefaults.standard.set(response.username,    forKey: "username")
        UserDefaults.standard.set(response.role,        forKey: "role")
    }

    func logout() {
        token    = nil
        username = nil
        role     = nil
        APIClient.shared.token = nil
        UserDefaults.standard.removeObject(forKey: "jwt_token")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "role")
    }
}
