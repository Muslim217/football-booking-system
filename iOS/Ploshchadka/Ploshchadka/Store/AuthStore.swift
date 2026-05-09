import Foundation
import Observation

@Observable
final class AuthStore {
    var token: String?
    var refreshToken: String?
    var username: String?
    var role: String?

    var isLoggedIn: Bool { token != nil }
    var isAdmin:    Bool { role == "ADMIN" }
    var isOwner:    Bool { role == "OWNER" }
    var isUser:     Bool { role == "USER" }

    init() {
        token        = UserDefaults.standard.string(forKey: "jwt_token")
        refreshToken = UserDefaults.standard.string(forKey: "jwt_refresh")
        username     = UserDefaults.standard.string(forKey: "username")
        role         = UserDefaults.standard.string(forKey: "role")
        APIClient.shared.token        = token
        APIClient.shared.refreshToken = refreshToken
        APIClient.shared.onTokenRefreshed = { [weak self] newToken in
            self?.token = newToken
            UserDefaults.standard.set(newToken, forKey: "jwt_token")
            APIClient.shared.token = newToken
        }
        APIClient.shared.onUnauthorized = { [weak self] in
            self?.logout()
        }
    }

    func saveAuth(_ response: AuthResponse) {
        token        = response.accessToken
        refreshToken = response.refreshToken
        username     = response.username
        role         = response.role
        APIClient.shared.token        = response.accessToken
        APIClient.shared.refreshToken = response.refreshToken
        UserDefaults.standard.set(response.accessToken, forKey: "jwt_token")
        UserDefaults.standard.set(response.refreshToken, forKey: "jwt_refresh")
        UserDefaults.standard.set(response.username,    forKey: "username")
        UserDefaults.standard.set(response.role,        forKey: "role")
    }

    func logout() {
        // Fire-and-forget: revoke refresh token on server
        if let rt = refreshToken {
            Task {
                try? await APIClient.shared.send(
                    "/auth/logout", method: "POST",
                    body: RefreshTokenRequest(refreshToken: rt)
                )
            }
        }
        token        = nil
        refreshToken = nil
        username     = nil
        role         = nil
        APIClient.shared.token        = nil
        APIClient.shared.refreshToken = nil
        UserDefaults.standard.removeObject(forKey: "jwt_token")
        UserDefaults.standard.removeObject(forKey: "jwt_refresh")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "role")
    }
}
