import XCTest
@testable import TBA

class MockMyTBA: MyTBA {

    let session: MockURLSession

    init() {
        self.session = MockURLSession()

        super.init(uuid: "abcd123", deviceName: "MyTBATesting", urlSession: session)
    }

    func sendStub(for task: URLSessionDataTask, code: Int = 200) {
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

        var filepath = components.path.replacingOccurrences(of: "/_ah/api/tbaMobile/v9/", with: "").replacingOccurrences(of: "/", with: "_")
        if code != 200 {
            filepath.append("_\(code)")
        }

        guard let resourceURL = Bundle(for: type(of: self)).url(forResource: filepath, withExtension: "json") else {
            XCTFail()
            return
        }

        do {
            let data = try Data(contentsOf: resourceURL)
            let response = HTTPURLResponse(url: requestURL, statusCode: code, httpVersion: nil, headerFields: nil)
            mockRequest.testResponse = response
            if let completionHandler = mockRequest.completionHandler {
                completionHandler(data, response, nil)
            }
        } catch {
            XCTFail()
        }
    }

}
