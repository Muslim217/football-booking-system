import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case network(Error)
    case http(Int, String)
    case decoding(Error)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:        return "Неверный URL"
        case .network(let e):    return "Ошибка сети: \(e.localizedDescription)"
        case .http(_, let msg):  return msg.isEmpty ? "Ошибка сервера" : msg
        case .decoding(let e):   return "Ошибка данных: \(e.localizedDescription)"
        case .unauthorized:      return "Сессия истекла. Войдите снова"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    var baseURL = "http://localhost:8080/api"
    var token: String?
    var refreshToken: String?

    // Callbacks set by AuthStore
    var onTokenRefreshed: ((String) -> Void)?
    var onUnauthorized: (() -> Void)?

    private let session: URLSession
    private let decoder: JSONDecoder
    private var isRefreshing = false

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
    }

    // MARK: - Request builder

    private func request(_ path: String, method: String, body: (any Encodable)?) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let isAuthPath = path.hasPrefix("/auth/")
        if let token, !isAuthPath {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        return req
    }

    // MARK: - Fetch with response

    func fetch<T: Decodable>(_ path: String, method: String = "GET", body: (any Encodable)? = nil) async throws -> T {
        let req = try request(path, method: method, body: body)
        let (data, response) = try await session.data(for: req)

        // Auto-refresh on 401
        if let http = response as? HTTPURLResponse, http.statusCode == 401,
           !path.hasPrefix("/auth/"), let rt = refreshToken, !isRefreshing {
            if let newToken = await tryRefresh(rt) {
                // Retry original request with new token
                var retryReq = req
                retryReq.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                let (retryData, retryResponse) = try await session.data(for: retryReq)
                try validate(response: retryResponse, data: retryData)
                return try decoder.decode(T.self, from: retryData)
            } else {
                onUnauthorized?()
                throw APIError.unauthorized
            }
        }

        try validate(response: response, data: data)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    // MARK: - Fetch paginated list

    func fetchPage<T: Decodable>(_ path: String, page: Int = 0, size: Int = 100) async throws -> [T] {
        let separator = path.contains("?") ? "&" : "?"
        let fullPath = "\(path)\(separator)page=\(page)&size=\(size)"
        let result: PageResponse<T> = try await fetch(fullPath)
        return result.content
    }

    // MARK: - Send without decoding response

    func send(_ path: String, method: String, body: (any Encodable)? = nil) async throws {
        let req = try request(path, method: method, body: body)
        let (data, response) = try await session.data(for: req)
        try validate(response: response, data: data)
    }

    // MARK: - Token refresh

    private func tryRefresh(_ refreshToken: String) async -> String? {
        isRefreshing = true
        defer { isRefreshing = false }
        guard let url = URL(string: baseURL + "/auth/refresh") else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(RefreshTokenRequest(refreshToken: refreshToken))
        guard let (data, response) = try? await session.data(for: req),
              let http = response as? HTTPURLResponse, http.statusCode == 200,
              let auth = try? decoder.decode(AuthResponse.self, from: data) else { return nil }
        self.token = auth.accessToken
        onTokenRefreshed?(auth.accessToken)
        return auth.accessToken
    }

    // MARK: - Validate HTTP response

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.network(URLError(.badServerResponse))
        }
        if http.statusCode == 401 { throw APIError.unauthorized }
        guard (200..<300).contains(http.statusCode) else {
            let msg = (try? decoder.decode(MessageResponse.self, from: data))?.message ?? ""
            throw APIError.http(http.statusCode, msg)
        }
    }
}
