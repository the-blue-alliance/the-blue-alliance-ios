import Foundation
import Testing

@testable import MyTBAKit

@MainActor
struct MyTBAErrorTests {

    @Test func code() {
        #expect(MyTBAError.error(nil, "").code == nil)
        #expect(MyTBAError.error(210, "").code == 210)
        #expect(MyTBAError.missingFCMToken.code == nil)
    }

    @Test func errorMessage() {
        let message = "Testing error message"
        #expect(MyTBAError.error(nil, message).localizedDescription == message)
    }

}

@MainActor
struct MyTBATests {

    let myTBA = MockMyTBA()

    @Test func initStoresIdentity() {
        let fcmTokenProvider = MockFCMTokenProvider()
        fcmTokenProvider.fcmToken = "abc"
        let subject = MyTBA(
            uuid: "abcd123",
            deviceName: "My Device",
            fcmTokenProvider: fcmTokenProvider,
            idTokenProvider: MockIDTokenProvider()
        )
        #expect(subject.uuid == "abcd123")
        #expect(subject.deviceName == "My Device")
        #expect(subject.fcmToken == "abc")
    }

    @Test func noBearerWhenSignedOut() async throws {
        myTBA.idTokenProvider.isSignedIn = false
        try myTBA.stub(for: "favorites/list")
        _ = try await myTBA.fetchFavorites()

        let request = try #require(myTBA.session.lastRequest)
        #expect(request.allHTTPHeaderFields?["Authorization"] == nil)
    }

    @Test func bearerWhenSignedIn() async throws {
        myTBA.idTokenProvider.isSignedIn = true
        myTBA.idTokenProvider.stubbedToken = "abcd123"
        try myTBA.stub(for: "favorites/list")
        _ = try await myTBA.fetchFavorites()

        let request = try #require(myTBA.session.lastRequest)
        #expect(request.httpMethod == "POST")
        #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer abcd123")
    }

}
