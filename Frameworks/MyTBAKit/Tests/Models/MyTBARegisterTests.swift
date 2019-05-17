import MyTBAKit
import MyTBAKitTesting
import XCTest

class MyTBARegisterTests: MyTBATestCase {

    func test_register() {
        let ex = expectation(description: "Register called")
        let operation = myTBA.register("abcd123") { (_, error) in
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation!)
        wait(for: [ex], timeout: 1.0)
    }

    func test_register_error() {
        let ex = expectation(description: "Register called")
        let operation = myTBA.register("abcd123") { (_, error) in
            XCTAssertNotNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation!, code: 401)
        wait(for: [ex], timeout: 1.0)
    }

}
