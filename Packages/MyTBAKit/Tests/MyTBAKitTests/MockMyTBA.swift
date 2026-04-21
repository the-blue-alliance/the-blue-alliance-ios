import TBATestingMocks
import XCTest
@testable import MyTBAKit

extension MockURLSession: MyTBAURLSession {}

// `@unchecked Sendable` on the mocks below because they have mutable
// stub state by design — tests set their seams during setup.

public final class MockFCMTokenProvider: FCMTokenProvider, @unchecked Sendable {
    public var fcmToken: String?

    public init(fcmToken: String?) {
        self.fcmToken = fcmToken
    }
}

public final class MockIDTokenProvider: IDTokenProvider, @unchecked Sendable {
    public var isSignedIn: Bool
    public var stubbedToken: String
    public var stubbedError: Error?

    public init(isSignedIn: Bool = false, stubbedToken: String = "mock-id-token") {
        self.isSignedIn = isSignedIn
        self.stubbedToken = stubbedToken
    }

    public func idToken() async throws -> String {
        if let stubbedError {
            throw stubbedError
        }
        return stubbedToken
    }
}

// Composition, not subclassing — `MyTBA` is an actor and can't be
// subclassed. This wrapper owns a real `MyTBA` plus the test seams.
public final class MockMyTBA: @unchecked Sendable {

    public let myTBA: MyTBA
    public let session: MockURLSession
    public let idTokenProvider: MockIDTokenProvider

    public init(
        fcmTokenProvider: FCMTokenProvider,
        idTokenProvider: MockIDTokenProvider = MockIDTokenProvider()
    ) {
        let session = MockURLSession()
        self.session = session
        self.idTokenProvider = idTokenProvider
        self.myTBA = MyTBA(
            uuid: "abcd123",
            deviceName: "MyTBATesting",
            fcmTokenProvider: fcmTokenProvider,
            idTokenProvider: idTokenProvider,
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
