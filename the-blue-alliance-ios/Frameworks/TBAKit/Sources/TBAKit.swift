import Foundation

public typealias TBAKitRequestCompletionBlock = (_ response: HTTPURLResponse?, _ json: Any?, _ error: Error?) -> ()

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

    private let apiKey: String
    private let urlSession: URLSession
    private let userDefaults: UserDefaults

    public init(apiKey: String, urlSession: URLSession? = nil, userDefaults: UserDefaults) {
        self.apiKey = apiKey
        self.urlSession = urlSession ?? URLSession(configuration: .default)
        self.userDefaults = userDefaults
    }

    private static func lastModifiedURLString(for url: URL) -> String {
        return "LAST_MODIFIED:\(url.absoluteString)"
    }

    private static func etagURLString(for url: URL) -> String {
        return "ETAG:\(url.absoluteString)"
    }

    /// Please do not use - if you need this for testing, use MockTBAKit.lastModified(:)
    public func lastModified(for url: URL) -> String? {
        let lastModifiedString = TBAKit.lastModifiedURLString(for: url)
        let lastModifiedDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.lastModifiedDictionary) ?? [:]
        return lastModifiedDictionary[lastModifiedString] as? String
    }

    public func setLastModified(_ request: URLSessionDataTask) {
        // Pull our response off of our request
        guard let httpResponse = request.response as? HTTPURLResponse else {
            return
        }
        // Grab our lastModified to store
        guard let lastModified = httpResponse.allHeaderFields["Last-Modified"] as? String else {
            return
        }
        // And finally, grab our URL
        guard let url = httpResponse.url else {
            return
        }

        let lastModifiedString = TBAKit.lastModifiedURLString(for: url)
        var lastModifiedDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.lastModifiedDictionary) ?? [:]
        lastModifiedDictionary[lastModifiedString] = lastModified

        userDefaults.set(lastModifiedDictionary, forKey: Constants.APIConstants.lastModifiedDictionary)
        userDefaults.synchronize()
    }

    public func clearLastModified() {
        userDefaults.removeObject(forKey: Constants.APIConstants.lastModifiedDictionary)
        userDefaults.synchronize()
    }

    /// Please do not use - if you need this for testing, use MockTBAKit.lastModified(:)
    public func etag(for url: URL) -> String? {
        let etagString = TBAKit.etagURLString(for: url)
        let etagDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.etagDictionary) ?? [:]
        return etagDictionary[etagString] as? String
    }

    public func setEtag(_ request: URLSessionDataTask) {
        // Pull our response off of our request
        guard let httpResponse = request.response as? HTTPURLResponse else {
            return
        }
        // Grab our lastModified to store
        guard let etag = httpResponse.allHeaderFields["Etag"] as? String else {
            return
        }
        // And finally, grab our URL
        guard let url = httpResponse.url else {
            return
        }

        let etagString = TBAKit.etagURLString(for: url)
        var etagDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.etagDictionary) ?? [:]
        etagDictionary[etagString] = etag

        userDefaults.set(etagDictionary, forKey: Constants.APIConstants.etagDictionary)
        userDefaults.synchronize()
    }

    public func clearEtag() {
        userDefaults.removeObject(forKey: Constants.APIConstants.etagDictionary)
        userDefaults.synchronize()
    }

    internal func callApi(method: String, completion: @escaping TBAKitRequestCompletionBlock) -> URLSessionDataTask {
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

        let task = urlSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            let httpResponse = response as? HTTPURLResponse
            guard let statusCode = httpResponse?.statusCode else {
                completion(httpResponse, nil, APIError.error("No status code for response"))
                return
            }
            
            if statusCode == 304 {
                completion(httpResponse, nil, nil)
                return
            }

            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let jsonDict = json as? [String: String], let apiError = jsonDict["Error"] {
                    completion(httpResponse, nil, APIError.error(apiError))
                } else {
                    completion(httpResponse, json, error)
                }
            } else {
                // Probably got a 'null' back from the API for the JSON
                completion(httpResponse, nil, error)
            }
        }
        task.resume()
        return task
    }
    
    internal func callObject<T: TBAModel>(method: String, completion: @escaping (Result<T?, Error>) -> ()) -> URLSessionDataTask {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(.failure(error))
            } else if let statusCode = response?.statusCode, statusCode == 304 {
                completion(.success(nil))
            } else if let json = json as? [String: Any] {
                completion(.success(T(json: json)))
            } else {
                completion(.failure(APIError.error("Unexpected response from server.")))
            }
        }
    }
    
    internal func callArray<T: TBAModel>(method: String, completion: @escaping (Result<[T], Error>) -> ()) -> URLSessionDataTask {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(.failure(error))
            } else if let statusCode = response?.statusCode, statusCode == 304 {
                completion(.success([]))
            } else if let json = json as? [[String: Any]] {
                let models = json.compactMap({
                    return T(json: $0)
                })
                completion(.success(models))
            } else {
                completion(.failure(APIError.error("Unexpected response from server.")))
            }
        }
    }
    
    internal func callArray(method: String, completion: @escaping (Result<[Any], Error>) -> ()) -> URLSessionDataTask {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(.failure(error))
            } else if let statusCode = response?.statusCode, statusCode == 304 {
                completion(.success([]))
            } else if let array = json as? [Any] {
                completion(.success(array))
            } else {
                completion(.failure(APIError.error("Unexpected response from server.")))
            }
        }
    }

    internal func callDictionary(method: String, completion: @escaping (Result<[String: Any], Error>) -> ()) -> URLSessionDataTask {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(.failure(error))
            } else if let statusCode = response?.statusCode, statusCode == 304 {
                completion(.success([:]))
            } else if let dict = json as? [String: Any] {
                completion(.success(dict))
            } else {
                completion(.failure(APIError.error("Unexpected response from server.")))
            }
        }
    }
    
}
