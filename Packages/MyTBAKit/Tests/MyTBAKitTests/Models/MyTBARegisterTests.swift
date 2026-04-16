import MyTBAKit
import XCTest

class MyTBARegisterTests: MyTBATestCase {

    func test_register() async throws {
        fcmTokenProvider.fcmToken = "abc"
        myTBA.stub(for: "register")
        _ = try await myTBA.register()
    }

    func test_register_error() async {
        fcmTokenProvider.fcmToken = "abc"
        myTBA.stub(for: "register", code: 401)
        do {
            _ = try await myTBA.register()
            XCTFail("Expected register to throw on 401")
        } catch {
            // expected
        }
    }

}
