import TBATestingMocks
import XCTest
@testable import MyTBAKit

public class MockFCMTokenProvider: FCMTokenProvider {
    public var fcmToken: String?

    public init(fcmToken: String?) {
        self.fcmToken = fcmToken
    }
}

public class MockMyTBA: MyTBA {

    let session: MockURLSession

    public init(fcmTokenProvider: FCMTokenProvider) {
        self.session = MockURLSession()

        super.init(uuid: "abcd123",
                   deviceName: "MyTBATesting",
                   fcmTokenProvider: fcmTokenProvider,
                   urlSession: session)
    }

    public func sendStub(for operation: MyTBAOperation, code: Int = 200) {
        guard let mockRequest = operation.task as? MockURLSessionDataTask else {
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

        var filepath = components.path.replacingOccurrences(of: "/clientapi/tbaClient/v9/", with: "").replacingOccurrences(of: "/", with: "_")
        if code != 200 {
            filepath.append("_\(code)")
        }

        guard let resourceURL = Bundle.module.url(forResource: "data/\(filepath)", withExtension: "json") else {
            XCTFail("Cannot find file \(filepath).json")
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
