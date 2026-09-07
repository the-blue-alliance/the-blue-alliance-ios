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

    // The server signals auth failure inside a 200 body. Before the envelope
    // check this decoded as an empty list, and the app would then wipe the
    // user's cached subscriptions with it.
    func test_subscriptions_unauthorized() async {
        myTBA.stub(for: "subscriptions/list", code: 401)
        do {
            _ = try await myTBA.fetchSubscriptions()
            XCTFail("Expected a 401 to throw")
        } catch let error as MyTBAError {
            XCTAssertEqual(error.code, 401)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

}
