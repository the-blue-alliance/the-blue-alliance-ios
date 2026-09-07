import Testing

@testable import MyTBAKit

struct MyTBASubscriptionTests {

    let myTBA = MockMyTBA()

    @Test func subscriptions() async throws {
        try myTBA.stub(for: "subscriptions/list")
        let subscriptions = try await myTBA.fetchSubscriptions()
        #expect(subscriptions.count == 3)
    }

    @Test func subscriptionsEmpty() async throws {
        try myTBA.stub(for: "subscriptions/list", code: 201)
        let subscriptions = try await myTBA.fetchSubscriptions()
        #expect(subscriptions.isEmpty)
    }

    @Test func subscriptionsUnauthorized() async throws {
        try myTBA.stub(for: "subscriptions/list", code: 401)
        let error = await #expect(throws: MyTBAError.self) {
            try await myTBA.fetchSubscriptions()
        }
        #expect(error?.code == 401)
    }

}
