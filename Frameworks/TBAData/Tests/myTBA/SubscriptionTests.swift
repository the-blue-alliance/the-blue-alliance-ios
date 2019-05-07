import TBAData
import MyTBAKit
import XCTest

class SubscriptionTestCase: TBADataTestCase {

    func test_notifications() {
        let subscription = Subscription.init(entity: Subscription.entity(), insertInto: viewContext)

        subscription.notificationsRaw = ["final_results"]
        XCTAssertEqual(subscription.notifications, [.finalResults])

        subscription.notifications = [.allianceSelection]
        XCTAssertEqual(subscription.notificationsRaw, ["alliance_selection"])
    }

    func test_predicate() {
        let predicate = Subscription.subscriptionPredicate(modelKey: "frc2337", modelType: .team)
        XCTAssertEqual(predicate.predicateFormat, "modelKey == \"frc2337\" AND modelTypeRaw == 1")
    }

    func test_insert_array() {
        let modelSubscriptionOne = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let modelSubscriptionTwo = MyTBASubscription(modelKey: "2017miket", modelType: .event, notifications: [.finalResults])

        Subscription.insert([modelSubscriptionOne, modelSubscriptionTwo], in: viewContext)
        let subscriptions = Subscription.fetch(in: viewContext)

        let subscriptionOne = subscriptions.first(where: { $0.modelKey == "2018miket" })!
        let subscriptionTwo = subscriptions.first(where: { $0.modelKey == "2017miket" })!

        // Sanity check
        XCTAssertNotEqual(subscriptionOne, subscriptionTwo)

        Subscription.insert([modelSubscriptionTwo], in: viewContext)
        let subscriptionsSecond = Subscription.fetch(in: viewContext)

        XCTAssertNoThrow(try viewContext.save())

        XCTAssertEqual(subscriptionsSecond, [subscriptionTwo])

        // SubscriptionOne should be deleted
        XCTAssertNil(subscriptionOne.managedObjectContext)

        // SubscriptionTwo should not be deleted
        XCTAssertNotNil(subscriptionTwo.managedObjectContext)
    }

    func test_insert_model() {
        let model = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscription = Subscription.insert(model, in: viewContext)

        XCTAssertEqual(subscription.modelKey, "2018miket")
        XCTAssertEqual(subscription.modelType, .event)
        XCTAssertEqual(subscription.notifications, [.awards])

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_insert_values() {
        let subscription = Subscription.insert(modelKey: "2018miket", modelType: .event, notifications: [.awards], in: viewContext)

        XCTAssertEqual(subscription.modelKey, "2018miket")
        XCTAssertEqual(subscription.modelType, .event)
        XCTAssertEqual(subscription.notifications, [.awards])

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_update() {
        let model = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscriptionOne = Subscription.insert(model, in: viewContext)

        // Sanity check
        XCTAssertEqual(subscriptionOne.notifications, [.awards])

        let subscriptionTwo = Subscription.insert(modelKey: model.modelKey, modelType: model.modelType, notifications: [.finalResults], in: viewContext)

        XCTAssertEqual(subscriptionOne, subscriptionTwo)
        XCTAssertEqual(subscriptionOne.notifications, [.finalResults])

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_delete() {
        let model = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscription = Subscription.insert(model, in: viewContext)

        viewContext.delete(subscription)
        XCTAssertNoThrow(try viewContext.save())
    }

    func test_toRemoteModel() {
        let model = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscription = Subscription.insert(model, in: viewContext)
        XCTAssertEqual(model, subscription.toRemoteModel())
    }

    func test_isOrphaned() {
        let subscription = Subscription.init(entity: Subscription.entity(), insertInto: viewContext)
        // Subscription should never be orphaned
        XCTAssertFalse(subscription.isOrphaned)
    }

}
