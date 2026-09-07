import Foundation

public enum MyTBAError: Error, Equatable, Sendable {
    case error(Int?, String)
    /// No FCM token, so this device was never registered and can't be.
    case missingFCMToken

    public var code: Int? {
        switch self {
        case .error(let code, _):
            return code
        case .missingFCMToken:
            return nil
        }
    }
}

extension MyTBAError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(_, let message):
            // TODO: This, unlike the name says, isn't localized
            return message
        case .missingFCMToken:
            return "Missing FCM token"
        }
    }
}

public protocol MyTBAURLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: MyTBAURLSession {}

open class MyTBA {

    static let baseURL = URL(string: "https://www.thebluealliance.com/clientapi/tbaClient/v9/")!

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

    internal var fcmToken: String? {
        return fcmTokenProvider.fcmToken
    }

    internal var urlSession: MyTBAURLSession
    internal var uuid: String
    internal var deviceName: String
    private var fcmTokenProvider: FCMTokenProvider
    private var idTokenProvider: IDTokenProvider

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
        let apiURL = URL(string: method, relativeTo: Self.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"

        // No token means unauthenticated; the server decides whether that's
        // acceptable for the endpoint.
        if let token = try await idTokenProvider.idToken() {
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

        // Errors come back as HTTP 200 with the code in the body (it's a port of
        // the old Cloud Endpoints API), and every response carries the envelope -
        // so check it first, before the payload type gets a say.
        let envelope = try MyTBA.jsonDecoder.decode(MyTBABaseResponse.self, from: data)
        if let error = envelope.error {
            throw error
        }
        return try MyTBA.jsonDecoder.decode(T.self, from: data)
    }

}
