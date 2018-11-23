import Foundation

public typealias TBAKitRequestCompletionBlock = (_ response: HTTPURLResponse?, _ json: Any?, _ error: Error?) -> ()

private struct Constants {
    struct APIConstants {
        static let baseURL = URL(string: "https://www.thebluealliance.com/api/v3/")!
        static let lastModifiedDictionary = "LastModifiedDictionary"
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

public class TBAKit: NSObject {

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

    /// Please do not use - if you need this for testing, use MockTBAKit.lastModified(:)
    func lastModified(for url: URL) -> String? {
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
    
    internal func callApi(method: String, completion: @escaping TBAKitRequestCompletionBlock) -> URLSessionDataTask {
        let apiURL = URL(string: method, relativeTo: Constants.APIConstants.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-TBA-Auth-Key")

        if let lastModified = lastModified(for: apiURL) {
            request.addValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
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
    
    internal func callObject<T: TBAModel>(method: String, completion: @escaping (T?, Error?) -> ()) -> URLSessionDataTask {
        return callApi(method: method) { (response, json, error) in
            var model: T?
            if let json = json as? [String: Any] {
                model = T(json: json)
            }
            completion(model, error)
        }
    }
    
    internal func callArray<T: TBAModel>(method: String, completion: @escaping ([T]?, Error?) -> ()) -> URLSessionDataTask {
        return callApi(method: method) { (response, json, error) in
            var models: [T]?
            if let json = json as? [[String: Any]] {
                models = []
                for result in json {
                    if let model = T(json: result) {
                        models!.append(model)
                    }
                }
            }
            completion(models, error)
        }
    }
    
    internal func callArray(method: String, completion: @escaping ([Any]?, Error?) -> ()) -> URLSessionDataTask {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let statusCode = response?.statusCode, statusCode == 304 {
                completion(nil, nil)
            } else if let array = json as? [Any] {
                completion(array, nil)
            } else {
                completion(nil, APIError.error("Unexpected response from server."))
            }
        }
    }

    internal func callDictionary(method: String, completion: @escaping ([String: Any]?, Error?) -> ()) -> URLSessionDataTask {
        return callApi(method: method) { (response, json, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let statusCode = response?.statusCode, statusCode == 304 {
                completion(nil, nil)
            } else if let dict = json as? [String: Any] {
                completion(dict, nil)
            } else {
                completion(nil, APIError.error("Unexpected response from server."))
            }
        }
    }
    
}
