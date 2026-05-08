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
        case .decoding:          return "Ошибка обработки данных"
        case .unauthorized:      return "Сессия истекла. Войдите снова"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    // MARK: - Configuration
    // Change to your server address when testing on a real device
    var baseURL = "http://localhost:8080/api"
    var token: String?

    private let session: URLSession
    private let decoder: JSONDecoder

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
        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        return req
    }

    // MARK: - Generic fetch with response body

    func fetch<T: Decodable>(_ path: String, method: String = "GET", body: (any Encodable)? = nil) async throws -> T {
        let req = try request(path, method: method, body: body)
        let (data, response) = try await session.data(for: req)
        try validate(response: response, data: data)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    // MARK: - Send without decoding response

    func send(_ path: String, method: String, body: (any Encodable)? = nil) async throws {
        let req = try request(path, method: method, body: body)
        let (data, response) = try await session.data(for: req)
        try validate(response: response, data: data)
    }

    // MARK: - Validate HTTP response

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.network(URLError(.badServerResponse))
        }
        if http.statusCode == 401 {
            throw APIError.unauthorized
        }
        guard (200..<300).contains(http.statusCode) else {
            let msg = (try? decoder.decode(MessageResponse.self, from: data))?.message ?? ""
            throw APIError.http(http.statusCode, msg)
        }
    }
}
