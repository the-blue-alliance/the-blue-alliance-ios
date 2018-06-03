import Foundation
import GTMSessionFetcher
import FirebaseMessaging

public typealias MyTBARequestCompletionBlock = (_ data: Data?, _ error: Error?) -> ()

struct Constants {
    struct APIConstants {
        static let baseURL = URL(string: "https://tbatv-prod-hrd.appspot.com/_ah/api/tbaMobile/v9/")!
    }
}

public enum APIError: Error {
    case error(String)
}

class MyTBA {
    public static let shared = MyTBA()
    
    var authentication: GTMFetcherAuthorizationProtocol? {
        didSet {
            fetcherService.authorizer = authentication
            authenticationProvider.post { (observer) in
                if authentication == nil {
                    observer.unauthenticated()
                } else {
                    observer.authenticated()
                }
            }
        }
    }
    var authenticationProvider = Provider<MyTBAAuthenticationObservable>()
    private var fetcherService: GTMSessionFetcherService
    
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
    
    init() {
        self.fetcherService = GTMSessionFetcherService()
    }
    
    func callApi<T: MyTBAResponse>(method: String, data: Data? = nil, completion: @escaping (T?, Error?) -> ()) -> GTMSessionFetcher {
        let apiURL = URL(string: method, relativeTo: Constants.APIConstants.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        
        #if DEBUG
        if let data = data, let dataString = try? JSONSerialization.jsonObject(with: data, options: []) {
            print("POST: \(dataString)")
        }
        #endif
        
        let sessionFetcher = fetcherService.fetcher(with: request)
        sessionFetcher.bodyData = data
        sessionFetcher.beginFetch { (data, error) in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                #if DEBUG
                if let dataString = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print(dataString)
                }
                #endif
                
                do {
                    let response = try MyTBA.jsonDecoder.decode(T.self, from: data)
                    completion(response, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, APIError.error("Unexpected response from myTBA API"))
            }
        }
        return sessionFetcher
    }

}

protocol MyTBAAuthenticationObservable {
    func authenticated()
    func unauthenticated()
}
