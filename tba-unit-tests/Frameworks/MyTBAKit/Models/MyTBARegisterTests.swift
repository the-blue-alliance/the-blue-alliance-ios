import XCTest
@testable import The_Blue_Alliance

class MyTBARegisterTests: MyTBATestCase {

    func test_register() {
        let ex = expectation(description: "Register called")
        let task = myTBA.register("abcd123") { (error) in
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: task!)
        wait(for: [ex], timeout: 1.0)
    }

    func test_register_error() {
        let ex = expectation(description: "Register called")
        let task = myTBA.register("abcd123") { (error) in
            XCTAssertNotNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: task!, code: 401)
        wait(for: [ex], timeout: 1.0)
    }

}
