import Foundation
import XCTest

class MockURLSessionDataTask: URLSessionDataTask {
    
    var resumeExpectation: XCTestExpectation?
    var cancelExpectation: XCTestExpectation?
    
    var testRequest: URLRequest?
    var testResponse: URLResponse?

    var completionHandler: ((Data?, URLResponse?, Error?) -> ())?
    
    override var response: URLResponse? {
        return testResponse
    }
    
    override var currentRequest: URLRequest? {
        if let testRequest = testRequest {
            return testRequest
        }
        return super.currentRequest
    }
    
    override var taskIdentifier: Int {
        return 2337
    }
    
    override func resume() {
        resumeExpectation?.fulfill()
    }
    
    override func cancel() {
        cancelExpectation?.fulfill()
    }
    
    func runCompletionHandler(with data: Data?, and error: Error?) {
        if let completionHandler = completionHandler {
            completionHandler(data, testResponse, error)
        }
    }
    
}
