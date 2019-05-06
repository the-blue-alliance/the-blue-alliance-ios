import TBAKit
import XCTest

public class MockTBAKit: TBAKit {

    public let session: MockURLSession
    private let bundle: Bundle

    public init(userDefaults: UserDefaults, bundle: Bundle) {
        self.session = MockURLSession()
        self.bundle = bundle

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

        return TBAKit.lastModifiedURLString(for: url)
    }

    public func etag(_ task: URLSessionDataTask) -> String? {
        // Pull our response off of our request
        guard let request = task.currentRequest else {
            return nil
        }
        // Grab our URL
        guard let url = request.url else {
            return nil
        }

        return TBAKit.etagURLString(for: url)
    }

    public func sendUnauthorizedStub(for task: URLSessionDataTask) {
        guard let mockRequest = task as? MockURLSessionDataTask else {
            XCTFail()
            return
        }
        guard let requestURL = mockRequest.testRequest?.url else {
            XCTFail()
            return
        }

        guard let resourceURL = bundle.url(forResource: "unauthorized", withExtension: "json") else {
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

    public func sendUnmodifiedStub(for task: URLSessionDataTask) {
        guard let mockRequest = task as? MockURLSessionDataTask else {
            XCTFail()
            return
        }
        guard let requestURL = mockRequest.testRequest?.url else {
            XCTFail()
            return
        }

        let headerFields = [
            "Last-Modified": "Sun, 11 Jun 2017 03:34:00 GMT",
            "Etag": "W/\"1ea6e1a87aafbbeeb6a89b31cf4fb84c\""
        ]
        let response = HTTPURLResponse(url: requestURL, statusCode: 304, httpVersion: nil, headerFields: headerFields)
        mockRequest.testResponse = response
        mockRequest.completionHandler?(nil, response, nil)
    }

    public func sendSuccessStub(for task: URLSessionDataTask, with code: Int = 200) {
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
        guard let resourceURL = bundle.url(forResource: "\(filepath)", withExtension: "json") else {
            XCTFail()
            return
        }

        var data: Data?
        do {
            data = try Data(contentsOf: resourceURL)
        } catch {
            XCTFail()
        }

        let headerFields = [
            "Last-Modified": "Sun, 11 Jun 2017 03:34:00 GMT",
            "Etag": "W/\"1ea6e1a87aafbbeeb6a89b31cf4fb84c\""
        ]
        let response = HTTPURLResponse(url: requestURL, statusCode: code, httpVersion: nil, headerFields: headerFields)
        mockRequest.testResponse = response
        mockRequest.completionHandler?(data, response, nil)
    }

}
