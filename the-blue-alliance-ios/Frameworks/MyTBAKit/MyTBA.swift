import Foundation
import FirebaseAuth
import FirebaseMessaging

public typealias MyTBARequestCompletionBlock = (_ data: Data?, _ error: Error?) -> Void

struct Constants {
    struct APIConstants {
        static let baseURL = URL(string: "https://zach-tba-dev.appspot.com/_ah/api/tbaMobile/v9/")!
    }
}

public enum APIError: Error {
    case error(String)
}

class MyTBA {

    public static let shared = MyTBA()
    private var authToken: String? {
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

    public init() {
        self.urlSession = URLSession(configuration: .default)

        // Block gets called on init - ignore the init call
        var initCall = true
        Auth.auth().addIDTokenDidChangeListener { (_, user) in
            if initCall {
                initCall = false
                return
            }

            if let user = user {
                user.getIDToken(completion: { (token, _) in
                    self.authToken = token
                })
            } else {
                self.authToken = nil
            }
        }
    }
    var authenticationProvider = Provider<MyTBAAuthenticationObservable>()
    private var urlSession: URLSession

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

                let response = try! MyTBA.jsonDecoder.decode(T.self, from: data)
                completion(response, nil)
            } else {
                completion(nil, APIError.error("Unexpected response from myTBA API"))
            }
        }
        task.resume()
        return task
    }

}

protocol MyTBAAuthenticationObservable {
    func authenticated()
    func unauthenticated()
}
