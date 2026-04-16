import MyTBAKit
import XCTest

class MyTBASubscriptionTests: MyTBATestCase {

    func test_subscriptions() async throws {
        myTBA.stub(for: "subscriptions/list")
        let subscriptions = try await myTBA.fetchSubscriptions()
        XCTAssertEqual(subscriptions.count, 3)
    }

    func test_subscriptions_empty() async throws {
        myTBA.stub(for: "subscriptions/list", code: 201)
        let subscriptions = try await myTBA.fetchSubscriptions()
        XCTAssertTrue(subscriptions.isEmpty)
    }

}
