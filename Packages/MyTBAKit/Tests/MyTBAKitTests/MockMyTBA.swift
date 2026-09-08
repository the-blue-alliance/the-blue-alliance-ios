import Foundation

@testable import MyTBAKit

extension MockURLSession: MyTBAURLSession {}

final class MockFCMTokenProvider: FCMTokenProvider {
    var fcmToken: String?
}

@MainActor
final class MockIDTokenProvider: IDTokenProvider {
    var isSignedIn = false
    var stubbedToken = "mock-id-token"
    var stubbedError: Error?

    func idToken() async throws -> String? {
        if let stubbedError {
            throw stubbedError
        }
        return isSignedIn ? stubbedToken : nil
    }
}

struct MissingFixture: Error {
    let name: String
}

/// A `MyTBA` whose collaborators are all controllable from a test.
final class MockMyTBA: MyTBA {

    let session = MockURLSession()
    let fcmTokenProvider = MockFCMTokenProvider()
    let idTokenProvider = MockIDTokenProvider()

    init() {
        super.init(
            uuid: "abcd123",
            deviceName: "MyTBATesting",
            fcmTokenProvider: fcmTokenProvider,
            idTokenProvider: idTokenProvider,
            urlSession: session
        )
    }

    /// Serves `data/<method>[_<code>].json` as the next response.
    func stub(for method: String, code: Int = 200) throws {
        var name = method.replacingOccurrences(of: "/", with: "_")
        if code != 200 {
            name.append("_\(code)")
        }
        guard let url = Bundle.module.url(forResource: "data/\(name)", withExtension: "json") else {
            throw MissingFixture(name: name)
        }
        session.stubbedData = try Data(contentsOf: url)
        session.stubbedResponse = HTTPURLResponse(
            url: URL(string: method, relativeTo: MyTBA.baseURL)!,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )
    }

}
