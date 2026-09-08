import Testing

@testable import MyTBAKit

@MainActor
struct MyTBARegisterTests {

    let myTBA = MockMyTBA()

    @Test func register() async throws {
        myTBA.fcmTokenProvider.fcmToken = "abc"
        try myTBA.stub(for: "register")
        _ = try await myTBA.register()
    }

    @Test func registerUnauthorized() async throws {
        myTBA.fcmTokenProvider.fcmToken = "abc"
        try myTBA.stub(for: "register", code: 401)
        let error = await #expect(throws: MyTBAError.self) {
            try await myTBA.register()
        }
        #expect(error?.code == 401)
    }

    @Test func registerWithoutTokenThrows() async {
        myTBA.fcmTokenProvider.fcmToken = nil
        await #expect(throws: MyTBAError.missingFCMToken) {
            try await myTBA.register()
        }
    }

}
