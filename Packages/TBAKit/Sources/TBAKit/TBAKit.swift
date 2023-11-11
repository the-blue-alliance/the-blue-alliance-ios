import Foundation

public typealias TBAKitOperationCompletion = (_ response: HTTPURLResponse?, _ json: Any?, _ error: Error?) -> ()

private struct Constants {
    struct APIConstants {
        static let baseURL = URL(string: "https://www.thebluealliance.com/api/v3/")!
        static let lastModifiedDictionary = "LastModifiedDictionary"
        static let etagDictionary = "EtagDictionary"
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

    public func storeCacheHeaders(_ operation: TBAKitOperation) {
        // Pull our response off of our request
        guard let httpResponse = operation.task.response as? HTTPURLResponse else {
            return
        }
        // Grab our lastModified to store
        let lastModified = httpResponse.allHeaderFields["Last-Modified"]
        // Grab our etag to store
        let etag = httpResponse.allHeaderFields["Etag"]

        // And finally, grab our URL
        guard let url = httpResponse.url else {
            return
        }

        if let lastModified = lastModified as? String {
            let lastModifiedString = TBAKit.lastModifiedURLString(for: url)
            var lastModifiedDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.lastModifiedDictionary) ?? [:]
            lastModifiedDictionary[lastModifiedString] = lastModified
            userDefaults.set(lastModifiedDictionary, forKey: Constants.APIConstants.lastModifiedDictionary)
        }
        if let etag = etag as? String {
            let etagString = TBAKit.etagURLString(for: url)
            var etagDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.etagDictionary) ?? [:]
            etagDictionary[etagString] = etag
            userDefaults.set(etagDictionary, forKey: Constants.APIConstants.etagDictionary)
        }
        userDefaults.synchronize()
    }

    public func clearCacheHeaders() {
        userDefaults.removeObject(forKey: Constants.APIConstants.lastModifiedDictionary)
        userDefaults.removeObject(forKey: Constants.APIConstants.etagDictionary)
        userDefaults.synchronize()
    }

    static func lastModifiedURLString(for url: URL) -> String {
        return "LAST_MODIFIED:\(url.absoluteString)"
    }

    static func etagURLString(for url: URL) -> String {
        return "ETAG:\(url.absoluteString)"
    }

    func lastModified(for url: URL) -> String? {
        let lastModifiedString = TBAKit.lastModifiedURLString(for: url)
        let lastModifiedDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.lastModifiedDictionary) ?? [:]
        return lastModifiedDictionary[lastModifiedString] as? String
    }

    func etag(for url: URL) -> String? {
        let etagString = TBAKit.etagURLString(for: url)
        let etagDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.etagDictionary) ?? [:]
        return etagDictionary[etagString] as? String
    }

    func createRequest(_ method: String) -> URLRequest {
        let apiURL = URL(string: method, relativeTo: Constants.APIConstants.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-TBA-Auth-Key")
        request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")

        if let lastModified = lastModified(for: apiURL) {
            request.addValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
        }

        if let etag = etag(for: apiURL) {
            request.addValue(etag, forHTTPHeaderField: "If-None-Match")
        }

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
