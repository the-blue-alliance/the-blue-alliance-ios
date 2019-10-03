import TBANetworkTestingMocks
import XCTest
@testable import MyTBAKit

public class MockMyTBA: MyTBA {

    let session: MockURLSession
    private let bundle: Bundle

    public init() {
        self.session = MockURLSession()

        let selfBundle = Bundle(for: type(of: self))
        guard let resourceURL = selfBundle.resourceURL?.appendingPathComponent("MyTBAKitTesting.bundle"),
            let bundle = Bundle(url: resourceURL) else {
                fatalError("Unable to find MyTBAKitTesting.bundle")
        }
        self.bundle = bundle

        super.init(uuid: "abcd123", deviceName: "MyTBATesting", urlSession: session)
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

        guard let resourceURL = bundle.url(forResource: filepath, withExtension: "json") else {
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
