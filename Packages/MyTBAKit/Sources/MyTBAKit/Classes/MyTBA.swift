import Foundation

private struct Constants {
    struct APIConstants {
        static let baseURL = URL(string: "https://www.thebluealliance.com/clientapi/tbaClient/v9/")!
    }
}

public enum MyTBAError: Error {
    case error(Int?, String)

    public var code: Int? {
        switch self {
        case .error(let code, _):
            return code
        }
    }
}

extension MyTBAError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(_, let message):
            // TODO: This, unlike the name says, isn't localized
            return message
        }
    }
}

public protocol MyTBAURLSession: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: MyTBAURLSession {}

public actor MyTBA {

    // Immutable after init — read freely from any isolation.
    nonisolated public let uuid: String
    nonisolated public let deviceName: String
    nonisolated public let fcmTokenProvider: FCMTokenProvider
    nonisolated public let idTokenProvider: IDTokenProvider
    nonisolated let urlSession: MyTBAURLSession

    // Synchronous UI guard — reads through the nonisolated provider. See
    // the PR description for why this is intentionally not actor-isolated.
    nonisolated public var isAuthenticated: Bool {
        idTokenProvider.isSignedIn
    }

    nonisolated var fcmToken: String? {
        fcmTokenProvider.fcmToken
    }

    // Actor-isolated auth-state broadcast state.
    private var authStateContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
    private var lastPostedAuthState: Bool?

    public init(
        uuid: String,
        deviceName: String,
        fcmTokenProvider: FCMTokenProvider,
        idTokenProvider: IDTokenProvider,
        urlSession: MyTBAURLSession? = nil
    ) {
        self.uuid = uuid
        self.deviceName = deviceName
        self.fcmTokenProvider = fcmTokenProvider
        self.idTokenProvider = idTokenProvider
        self.urlSession = urlSession ?? URLSession(configuration: .default)
    }

    // Replay-on-subscribe multicast of auth-state changes. Emits the
    // current value immediately, then every change driven by the host
    // app's `notifyAuthStateChanged`.
    public func authStateChanges() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let id = UUID()
            authStateContinuations[id] = continuation
            continuation.yield(isAuthenticated)
        }
    }

    // Called by the host app when the underlying auth identity changes
    // (sign-in / sign-out). Token refreshes in between do not flow through
    // here — they're picked up per-request via `idTokenProvider.idToken()`.
    //
    // Also prunes any continuations whose consumers have cancelled:
    // `yield` on a finished continuation is a safe no-op and returns
    // `.terminated`, so we use the state change as a natural GC point.
    public func notifyAuthStateChanged(isAuthenticated: Bool) {
        guard lastPostedAuthState != isAuthenticated else { return }
        lastPostedAuthState = isAuthenticated
        authStateContinuations = authStateContinuations.filter { _, continuation in
            if case .terminated = continuation.yield(isAuthenticated) {
                return false
            }
            return true
        }
    }

    static var jsonEncoder: JSONEncoder {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        return jsonEncoder
    }

    static var jsonDecoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }

    func createRequest(_ method: String, _ bodyData: Data? = nil) async throws -> URLRequest {
        let apiURL = URL(string: method, relativeTo: Constants.APIConstants.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"

        if idTokenProvider.isSignedIn {
            let token = try await idTokenProvider.idToken()
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        #if DEBUG
            if let bodyData = bodyData,
                let dataString = try? JSONSerialization.jsonObject(with: bodyData, options: [])
            {
                print("POST \(method): \(dataString)")
            }
        #endif

        request.httpBody = bodyData

        return request
    }

    func callApi<T: MyTBAResponse>(method: String, bodyData: Data? = nil) async throws -> T {
        let request = try await createRequest(method, bodyData)
        let (data, response) = try await urlSession.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode == 500 {
            throw MyTBAError.error(500, "Internal server error")
        }

        #if DEBUG
            if let dataString = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(dataString)
            }
        #endif

        let decoded = try MyTBA.jsonDecoder.decode(T.self, from: data)

        if let base = decoded as? MyTBABaseResponse, let error = base.error {
            throw error
        }

        return decoded
    }

}
