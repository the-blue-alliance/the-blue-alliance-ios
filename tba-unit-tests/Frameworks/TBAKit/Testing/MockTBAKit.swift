import XCTest
@testable import The_Blue_Alliance

class MockTBAKit: TBAKit {

    let session: MockURLSession

    init() {
        self.session = MockURLSession()
        super.init(apiKey: "abcd123", urlSession: session)
    }
    
    func sendUnauthorizedStub(for task: URLSessionDataTask) {
        guard let mockRequest = task as? MockURLSessionDataTask else {
            XCTFail()
            return
        }
        guard let requestURL = mockRequest.testRequest?.url else {
            XCTFail()
            return
        }

        guard let resourceURL = Bundle(for: type(of: self)).url(forResource: "unauthorized", withExtension: "json") else {
            XCTFail()
            return
        }

        do {
            let data = try Data(contentsOf: resourceURL)
            let response = HTTPURLResponse(url: requestURL, statusCode: 401, httpVersion: nil, headerFields: nil)
            mockRequest.testResponse = response
            if let completionHandler = mockRequest.completionHandler {
                completionHandler(data, response, nil)
            }
        } catch {
            XCTFail()
        }
    }

    func sendSuccessStub(for task: URLSessionDataTask, with code: Int = 200, headerFields: [String : String]? = nil) {
        guard let mockRequest = task as? MockURLSessionDataTask else {
            XCTFail()
            return
        }
        guard let requestURL = mockRequest.testRequest?.url else {
            XCTFail()
            return
        }
        guard let components = URLComponents(string: requestURL.absoluteString) else {
            XCTFail()
            return
        }

        let filepath = components.path.replacingOccurrences(of: "/api/v3/", with: "").replacingOccurrences(of: "/", with: "_")
        guard let resourceURL = Bundle(for: type(of: self)).url(forResource: "\(filepath)", withExtension: "json") else {
            XCTFail()
            return
        }

        do {
            let data = try Data(contentsOf: resourceURL)
            let response = HTTPURLResponse(url: requestURL, statusCode: code, httpVersion: nil, headerFields: headerFields)
            mockRequest.testResponse = response
            if let completionHandler = mockRequest.completionHandler {
                completionHandler(data, response, nil)
            }
        } catch {
            XCTFail()
        }
    }

}
