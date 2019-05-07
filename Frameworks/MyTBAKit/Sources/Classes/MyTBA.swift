import Foundation

public typealias MyTBARequestCompletionBlock = (_ data: Data?, _ error: Error?) -> Void

private struct Constants {
    struct APIConstants {
        static let baseURL = URL(string: "https://tbatv-prod-hrd.appspot.com/clientapi/tbaClient/v9/")!
    }
}

public enum MyTBAError: Error {
    case error(String)
}

extension MyTBAError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(message: let message):
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

    public init(uuid: String, deviceName: String, urlSession: URLSession? = nil) {
        self.uuid = uuid
        self.deviceName = deviceName
        self.urlSession = urlSession ?? URLSession(configuration: .default)
    }
    public var authenticationProvider = Provider<MyTBAAuthenticationObservable>()

    internal var urlSession: URLSession
    internal var uuid: String
    internal var deviceName: String

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

    func callApi<T: MyTBAResponse>(method: String, bodyData: Data? = nil, completion: @escaping (T?, Error?) -> Void) -> URLSessionDataTask {
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

        let task = urlSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                #if DEBUG
                if let dataString = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print(dataString)
                }
                #endif

                var decodedResponse: T?
                do {
                    decodedResponse = try MyTBA.jsonDecoder.decode(T.self, from: data)
                } catch {
                    completion(nil, error)
                    return
                }

                if let myTBAResponse = decodedResponse as? MyTBABaseResponse {
                    completion(decodedResponse, error ?? myTBAResponse.error)
                } else {
                    completion(decodedResponse, error)
                }
            } else {
                completion(nil, MyTBAError.error("Unexpected response from myTBA API"))
            }
        }
        task.resume()
        return task
    }

}

public protocol MyTBAAuthenticationObservable {
    func authenticated()
    func unauthenticated()
}
