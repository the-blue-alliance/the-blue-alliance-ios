import Foundation
import TBAOperation

public class MyTBAOperation: TBAOperation {

    var task: URLSessionTask!

    public init<T: MyTBAResponse>(myTBA: MyTBA, method: String, bodyData: Data? = nil, completion: @escaping (T?, Error?) -> Void) {
        super.init()

        let request = myTBA.createRequest(method, bodyData)
        task = myTBA.urlSession.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
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
                    self?.finish()
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
