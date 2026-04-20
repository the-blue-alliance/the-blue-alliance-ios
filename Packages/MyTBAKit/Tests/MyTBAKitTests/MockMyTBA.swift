import TBATestingMocks
import XCTest
@testable import MyTBAKit

extension MockURLSession: MyTBAURLSession {}

public class MockFCMTokenProvider: FCMTokenProvider {
    public var fcmToken: String?

    public init(fcmToken: String?) {
        self.fcmToken = fcmToken
    }
}

public class MockMyTBA: MyTBA {

    public let session: MockURLSession

    public init(fcmTokenProvider: FCMTokenProvider) {
        self.session = MockURLSession()

        super.init(
            uuid: "abcd123",
            deviceName: "MyTBATesting",
            fcmTokenProvider: fcmTokenProvider,
            urlSession: session
        )
    }

    public func stub(for method: String, code: Int = 200) {
        var filepath = method.replacingOccurrences(of: "/", with: "_")
        if code != 200 {
            filepath.append("_\(code)")
        }

        guard
            let resourceURL = Bundle.module.url(
                forResource: "data/\(filepath)",
                withExtension: "json"
            )
        else {
            XCTFail("Cannot find file \(filepath).json")
            return
        }

        do {
            session.stubbedData = try Data(contentsOf: resourceURL)
            let url = URL(
                string: method,
                relativeTo: URL(string: "https://www.thebluealliance.com/clientapi/tbaClient/v9/")!
            )!
            session.stubbedResponse = HTTPURLResponse(
                url: url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
        } catch {
            XCTFail("\(error)")
        }
    }

}
