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

public protocol MyTBAURLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: MyTBAURLSession {}

open class MyTBA {

    public var isAuthenticated: Bool {
        return idTokenProvider.isSignedIn
    }

    // Called by the host app when the underlying auth identity changes
    // (sign-in / sign-out). Token refreshes in between do not flow through
    // here — they're picked up per-request via `idTokenProvider.idToken()`.
    public func notifyAuthStateChanged(isAuthenticated: Bool) {
        if lastPostedAuthState == isAuthenticated {
            return
        }
        lastPostedAuthState = isAuthenticated
        authenticationProvider.post { observer in
            if isAuthenticated {
                observer.authenticated()
            } else {
                observer.unauthenticated()
            }
        }
    }

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

    public var authenticationProvider = Provider<MyTBAAuthenticationObservable>()

    internal var fcmToken: String? {
        return fcmTokenProvider.fcmToken
    }

    internal var urlSession: MyTBAURLSession
    internal var uuid: String
    internal var deviceName: String
    private var fcmTokenProvider: FCMTokenProvider
    private var idTokenProvider: IDTokenProvider
    private var lastPostedAuthState: Bool?

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

public protocol MyTBAAuthenticationObservable {
    func authenticated()
    func unauthenticated()
}
