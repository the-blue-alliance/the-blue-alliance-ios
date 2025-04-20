import Foundation

public typealias TBAKitOperationCompletion = (_ response: HTTPURLResponse?, _ json: Any?, _ error: Error?) -> ()

private struct Constants {
    struct APIConstants {
        static let baseURL = URL(string: "https://www.thebluealliance.com/api/v3/")!
    }
}

public enum APIError: Error {
    case error(String)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(message: let message):
            // TODO: This, unlike the name says, isn't localized
            return message
        }
    }
}

internal protocol TBAModel {
    init?(json: [String: Any])
}

open class TBAKit: NSObject {

    internal let apiKey: String
    internal let sessionProvider: (() -> URLSession)
    internal let userDefaults: UserDefaults

    public init(apiKey: String, sessionProvider: (() -> URLSession)? = nil, userDefaults: UserDefaults) {
        self.apiKey = apiKey
        if let sessionProvider = sessionProvider {
            self.sessionProvider = sessionProvider
        } else {
            self.sessionProvider = {
                return URLSession.init(configuration: .default)
            }
        }
        self.userDefaults = userDefaults
    }

    public func clearCache() {
        let session = sessionProvider()
        session.configuration.urlCache?.removeAllCachedResponses()
    }

    func createRequest(_ method: String) -> URLRequest {
        let apiURL = URL(string: method, relativeTo: Constants.APIConstants.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-TBA-Auth-Key")
        request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        return request
    }

    func callApi(method: String, completion: @escaping (_ response: HTTPURLResponse?, _ json: Any?, _ error: Error?) -> ()) -> TBAKitOperation {
        return TBAKitOperation(tbaKit: self, method: method, completion: completion)
    }

    func callObject<T: TBAModel>(method: String, completion: @escaping (Result<T?, Error>, Bool) -> ()) -> TBAKitOperation {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(.failure(error), false)
            } else if let statusCode = response?.statusCode, statusCode == 304 {
                completion(.success(nil), true)
            } else if let json = json as? [String: Any] {
                completion(.success(T(json: json)), false)
            } else {
                completion(.failure(APIError.error("Unexpected response from server.")), false)
            }
        }
    }

    func callArray<T: TBAModel>(method: String, completion: @escaping (Result<[T], Error>, Bool) -> ()) -> TBAKitOperation {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(.failure(error), false)
            } else if let statusCode = response?.statusCode, statusCode == 304 {
                completion(.success([]), true)
            } else if let json = json as? [[String: Any]] {
                let models = json.compactMap({
                    return T(json: $0)
                })
                completion(.success(models), false)
            } else {
                completion(.failure(APIError.error("Unexpected response from server.")), false)
            }
        }
    }

    func callArray(method: String, completion: @escaping (Result<[Any], Error>, Bool) -> ()) -> TBAKitOperation {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(.failure(error), false)
            } else if let statusCode = response?.statusCode, statusCode == 304 {
                completion(.success([]), true)
            } else if let array = json as? [Any] {
                completion(.success(array), false)
            } else {
                completion(.failure(APIError.error("Unexpected response from server.")), false)
            }
        }
    }

    func callDictionary(method: String, completion: @escaping (Result<[String: Any], Error>, Bool) -> ()) -> TBAKitOperation {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(.failure(error), false)
            } else if let statusCode = response?.statusCode, statusCode == 304 {
                completion(.success([:]), true)
            } else if let dict = json as? [String: Any] {
                completion(.success(dict), false)
            } else {
                completion(.failure(APIError.error("Unexpected response from server.")), false)
            }
        }
    }

}
