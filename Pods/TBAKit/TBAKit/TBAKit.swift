//
//  TBAKit.swift
//  Pods
//
//  Created by Zach Orr on 1/7/17.
//
//

import UIKit

public typealias TBAKitRequestCompletionBlock = (_ response: HTTPURLResponse?, _ json: Any?, _ error: Error?) -> ()

struct Constants {
    struct APIConstants {
        static let baseURL = URL(string: "https://www.thebluealliance.com/api/v3/")!
        static let lastModifiedDictionary = "LastModifiedDictionary"
    }
}

public enum APIError: Error {
    case error(String)
}

internal protocol TBAModel {
    init?(json: [String: Any])
}

public class TBAKit: NSObject {
    public static let sharedKit = TBAKit()
    public var apiKey: String?
    public var urlSession: URLSession

    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    
    public init(apiKey: String? = nil) {
        self.apiKey = apiKey
        self.urlSession = URLSession(configuration: .default)
    }
    
    private static func lastModifiedURLString(for url: URL) -> String {
        return "LAST_MODIFIED:\(url.absoluteString)"
    }
    
    private static func lastModified(for url: URL) -> String? {
        let lastModifiedString = lastModifiedURLString(for: url)
        let lastModifiedDictionary = UserDefaults.standard.dictionary(forKey: Constants.APIConstants.lastModifiedDictionary) ?? [:]
        return lastModifiedDictionary[lastModifiedString] as? String
    }
    
    private static func setLastModified(lastModified: String, for url: URL) {
        let lastModifiedString = lastModifiedURLString(for: url)
        var lastModifiedDictionary = UserDefaults.standard.dictionary(forKey: Constants.APIConstants.lastModifiedDictionary) ?? [:]
        lastModifiedDictionary[lastModifiedString] = lastModified

        UserDefaults.standard.set(lastModifiedDictionary, forKey: Constants.APIConstants.lastModifiedDictionary)
        UserDefaults.standard.synchronize()
    }
    
    public static func clearLastModified() {
        UserDefaults.standard.removeObject(forKey: Constants.APIConstants.lastModifiedDictionary)
        UserDefaults.standard.synchronize()
    }
    
    internal func callApi(method: String, completion: @escaping TBAKitRequestCompletionBlock) -> URLSessionDataTask {
        let apiURL = URL(string: method, relativeTo: Constants.APIConstants.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        
        if let apiKey = apiKey {
            request.addValue(apiKey, forHTTPHeaderField: "X-TBA-Auth-Key")
        }
        
        if let lastModified = TBAKit.lastModified(for: apiURL) {
            request.addValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
        }
        
        let task = urlSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            
            if statusCode == 304 {
                completion(httpResponse, nil, nil)
                return
            }
            
            // Set LastModified
            if let headers = httpResponse?.allHeaderFields, let lastModified = headers["Last-Modified"] as? String, let url = response?.url {
                TBAKit.setLastModified(lastModified: lastModified, for: url)
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