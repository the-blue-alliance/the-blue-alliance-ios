import XCTest
@testable import TBA

class MyTBASubscriptionTests: MyTBATestCase {

    func test_subscriptions() {
        let ex = expectation(description: "subscriptions/list called")
        let task = myTBA.fetchSubscriptions { (subscriptions, error) in
            XCTAssertNotNil(subscriptions)
            XCTAssertEqual(subscriptions?.count, 3)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: task)
        wait(for: [ex], timeout: 1.0)
    }

    func test_subscriptions_empty() {
        let ex = expectation(description: "subscriptions/list called")
        let task = myTBA.fetchSubscriptions { (subscriptions, error) in
            XCTAssertNil(subscriptions)
            XCTAssertNil(error)
            ex.fulfill()
        }
        myTBA.sendStub(for: task, code: 201)
        wait(for: [ex], timeout: 1.0)
    }

}
