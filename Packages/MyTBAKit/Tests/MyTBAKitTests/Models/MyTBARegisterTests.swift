import MyTBAKit
import XCTest

class MyTBARegisterTests: MyTBATestCase {

    func test_register() {
        fcmTokenProvider.fcmToken = "abc"

        let ex = expectation(description: "Register called")
        let operation = myTBA.register { (_, error) in
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation!)
        wait(for: [ex], timeout: 1.0)
    }

    func test_register_error() {
        fcmTokenProvider.fcmToken = "abc"

        let ex = expectation(description: "Register called")
        let operation = myTBA.register { (_, error) in
            XCTAssertNotNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation!, code: 401)
        wait(for: [ex], timeout: 1.0)
    }

}
