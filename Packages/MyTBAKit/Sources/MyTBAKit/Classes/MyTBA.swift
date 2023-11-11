import Foundation
import TBAUtils

public typealias MyTBARequestCompletionBlock = (_ data: Data?, _ error: Error?) -> Void

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

open class MyTBA {

    // This is public, which is terrible, because it shouldn't be. But we need it so in TBA
    // when Firebase Auth changes, we can remove the token
    public var authToken: String? {
        didSet {
            // Only disaptch on changed state
            if oldValue == authToken {
                return
            }

            authenticationProvider.post { (observer) in
                if authToken == nil {
                    observer.unauthenticated()
                } else {
                    observer.authenticated()
                }
            }
        }
    }

    public var isAuthenticated: Bool {
        return authToken != nil
    }

    public init(uuid: String, deviceName: String, fcmTokenProvider: FCMTokenProvider, urlSession: URLSession? = nil) {
        self.uuid = uuid
        self.deviceName = deviceName
        self.fcmTokenProvider = fcmTokenProvider
        self.urlSession = urlSession ?? URLSession(configuration: .default)
    }

    public var authenticationProvider = Provider<MyTBAAuthenticationObservable>()

    internal var fcmToken: String? {
        return fcmTokenProvider.fcmToken
    }

    internal var urlSession: URLSession
    internal var uuid: String
    internal var deviceName: String
    private var fcmTokenProvider: FCMTokenProvider

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

    func createRequest(_ method: String, _ bodyData: Data? = nil) -> URLRequest {
        let apiURL = URL(string: method, relativeTo: Constants.APIConstants.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"

        if let authToken = authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        #if DEBUG
        if let bodyData = bodyData, let dataString = try? JSONSerialization.jsonObject(with: bodyData, options: []) {
            print("POST \(method): \(dataString)")
        }
        #endif

        request.httpBody = bodyData

        return request
    }

    func callApi<T: MyTBAResponse>(method: String, bodyData: Data? = nil, completion: @escaping (T?, Error?) -> Void) -> MyTBAOperation {
        return MyTBAOperation(myTBA: self, method: method, bodyData: bodyData, completion: completion)
    }

}

public protocol MyTBAAuthenticationObservable {
    func authenticated()
    func unauthenticated()
}
