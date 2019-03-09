import XCTest
@testable import TBA

class MockTBAKit: TBAKit {

    let session: MockURLSession

    init(userDefaults: UserDefaults) {
        self.session = MockURLSession()

        super.init(apiKey: "abcd123", urlSession: session, userDefaults: userDefaults)
    }

    public func lastModified(_ task: URLSessionDataTask) -> String? {
        // Pull our response off of our request
        guard let request = task.currentRequest else {
            return nil
        }
        // Grab our URL
        guard let url = request.url else {
            return nil
        }

        return lastModified(for: url)
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

        var data: Data?
        do {
            data = try Data(contentsOf: resourceURL)
        } catch {
            XCTFail()
        }

        let response = HTTPURLResponse(url: requestURL, statusCode: 401, httpVersion: nil, headerFields: nil)
        mockRequest.testResponse = response
        mockRequest.completionHandler?(data, response, nil)
    }

    func sendUnmodifiedStub(for task: URLSessionDataTask) {
        guard let mockRequest = task as? MockURLSessionDataTask else {
            XCTFail()
            return
        }
        guard let requestURL = mockRequest.testRequest?.url else {
            XCTFail()
            return
        }

        let headerFields = ["Last-Modified": "Sun, 11 Jun 2017 03:34:00 GMT"]
        let response = HTTPURLResponse(url: requestURL, statusCode: 304, httpVersion: nil, headerFields: headerFields)
        mockRequest.testResponse = response
        mockRequest.completionHandler?(nil, response, nil)
    }

    func sendSuccessStub(for task: URLSessionDataTask, with code: Int = 200) {
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

        var data: Data?
        do {
            data = try Data(contentsOf: resourceURL)
        } catch {
            XCTFail()
        }

        let headerFields = ["Last-Modified": "Sun, 11 Jun 2017 03:34:00 GMT"]
        let response = HTTPURLResponse(url: requestURL, statusCode: code, httpVersion: nil, headerFields: headerFields)
        mockRequest.testResponse = response
        mockRequest.completionHandler?(data, response, nil)
    }

}
