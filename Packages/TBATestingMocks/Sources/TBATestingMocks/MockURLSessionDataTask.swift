import XCTest

public class MockURLSessionDataTask: URLSessionDataTask {
    
    public var resumeExpectation: XCTestExpectation?
    public var cancelExpectation: XCTestExpectation?
    
    public var testRequest: URLRequest?
    public var testResponse: URLResponse?

    public var completionHandler: ((Data?, URLResponse?, Error?) -> ())?
    
    override public var response: URLResponse? {
        return testResponse
    }
    
    override public var currentRequest: URLRequest? {
        if let testRequest = testRequest {
            return testRequest
        }
        return super.currentRequest
    }
    
    override public var taskIdentifier: Int {
        return 2337
    }
    
    override public func resume() {
        resumeExpectation?.fulfill()
    }
    
    override public func cancel() {
        cancelExpectation?.fulfill()
    }
    
    func runCompletionHandler(with data: Data?, and error: Error?) {
        if let completionHandler = completionHandler {
            completionHandler(data, testResponse, error)
        }
    }
    
}
