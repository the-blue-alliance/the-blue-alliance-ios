import MyTBAKit
import XCTest

class MyTBASubscriptionTests: MyTBATestCase {

    func test_subscriptions() {
        let ex = expectation(description: "subscriptions/list called")
        let operation = myTBA.fetchSubscriptions { (subscriptions, error) in
            XCTAssertNotNil(subscriptions)
            XCTAssertEqual(subscriptions?.count, 3)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation)
        wait(for: [ex], timeout: 1.0)
    }

    func test_subscriptions_empty() {
        let ex = expectation(description: "subscriptions/list called")
        let operation = myTBA.fetchSubscriptions { (subscriptions, error) in
            XCTAssertNil(subscriptions)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: operation, code: 201)
        wait(for: [ex], timeout: 1.0)
    }

}
