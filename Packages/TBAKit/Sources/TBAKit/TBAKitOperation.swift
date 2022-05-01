import Foundation
import TBAOperation

public class TBAKitOperation: TBAOperation {

    var task: URLSessionTask!

    public init(tbaKit: TBAKit, method: String, completion: @escaping TBAKitOperationCompletion) {
        super.init()

        let request = tbaKit.createRequest(method)

        let urlSession = tbaKit.sessionProvider()
        task = urlSession.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            let httpResponse = response as? HTTPURLResponse
            guard let statusCode = httpResponse?.statusCode else {
                completion(httpResponse, nil, APIError.error("No status code for response"))
                self?.finish()
                return
            }

            if statusCode == 304 {
                completion(httpResponse, nil, nil)
                self?.finish()
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
            self?.finish()
        }
    }

    override open func execute() {
        task.resume()
    }

    override open func cancel() {
        task.cancel()

        super.cancel()
    }

}
