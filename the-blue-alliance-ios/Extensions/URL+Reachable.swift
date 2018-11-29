import Foundation

extension Optional where Wrapped == URL {

    // Check if a given URL is reachable
    // Returns the wrapped URL if the URL is reachable, nil if the URL is not reacahble
    var reachableURL: URL? {
        // Check URL type
        switch self {
        case .some(let url):
            if url.isFileURL, (try? url.checkResourceIsReachable()) ?? false {
                return url
            } else if url.checkRemoteURLIsReachable() == true {
                return url
            }
            return nil
        case _:
            return nil
        }
    }

}

extension URL {

    fileprivate func checkRemoteURLIsReachable() -> Bool {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"

        let (data, _, error) = URLSession.shared.synchronousDataTask(with: request)
        return data != nil && error == nil
    }

}

// https://stackoverflow.com/a/34308158/537341
extension URLSession {

    func synchronousDataTask(with request: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: request) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }

}
