import Foundation
import Testing

@testable import MyTBAKit

@MainActor
struct MyTBARegisterTests {

    let myTBA = MockMyTBA()

    @Test func register() async throws {
        myTBA.fidProvider.fid = "abc"
        try myTBA.stub(for: "register")
        _ = try await myTBA.register()
    }

    @Test func registerSendsFID() async throws {
        myTBA.fidProvider.fid = "abc"
        try myTBA.stub(for: "register")
        _ = try await myTBA.register()

        let request = try #require(myTBA.session.lastRequest)
        let body = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: String])
        #expect(json["mobile_id"] == "abc")
        #expect(json["mobile_id_type"] == "fid")
        #expect(json["operating_system"] == "ios")
    }

    @Test func registerUnauthorized() async throws {
        myTBA.fidProvider.fid = "abc"
        try myTBA.stub(for: "register", code: 401)
        let error = await #expect(throws: MyTBAError.self) {
            try await myTBA.register()
        }
        #expect(error?.code == 401)
    }

    @Test func registerWithoutFIDThrows() async {
        myTBA.fidProvider.fid = nil
        await #expect(throws: MyTBAError.missingFID) {
            try await myTBA.register()
        }
    }

}
