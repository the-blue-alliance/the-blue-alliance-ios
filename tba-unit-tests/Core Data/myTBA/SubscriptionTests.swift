import Foundation
import XCTest
@testable import TBA

class SubscriptionTestCase: CoreDataTestCase {

    func test_notifications() {
        let subscription = Subscription.init(entity: Subscription.entity(), insertInto: persistentContainer.viewContext)

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

        Subscription.insert([modelSubscriptionOne, modelSubscriptionTwo], in: persistentContainer.viewContext)
        let subscriptions = Subscription.fetch(in: persistentContainer.viewContext)

        let subscriptionOne = subscriptions.first(where: { $0.modelKey == "2018miket" })!
        let subscriptionTwo = subscriptions.first(where: { $0.modelKey == "2017miket" })!

        // Sanity check
        XCTAssertNotEqual(subscriptionOne, subscriptionTwo)

        Subscription.insert([modelSubscriptionTwo], in: persistentContainer.viewContext)
        let subscriptionsSecond = Subscription.fetch(in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(subscriptionsSecond, [subscriptionTwo])

        // SubscriptionOne should be deleted
        XCTAssertNil(subscriptionOne.managedObjectContext)

        // SubscriptionTwo should not be deleted
        XCTAssertNotNil(subscriptionTwo.managedObjectContext)
    }

    func test_insert_model() {
        let model = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscription = Subscription.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(subscription.modelKey, "2018miket")
        XCTAssertEqual(subscription.modelType, .event)
        XCTAssertEqual(subscription.notifications, [.awards])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_values() {
        let subscription = Subscription.insert(modelKey: "2018miket", modelType: .event, notifications: [.awards], in: persistentContainer.viewContext)

        XCTAssertEqual(subscription.modelKey, "2018miket")
        XCTAssertEqual(subscription.modelType, .event)
        XCTAssertEqual(subscription.notifications, [.awards])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let model = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscriptionOne = Subscription.insert(model, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(subscriptionOne.notifications, [.awards])

        let subscriptionTwo = Subscription.insert(modelKey: model.modelKey, modelType: model.modelType, notifications: [.finalResults], in: persistentContainer.viewContext)

        XCTAssertEqual(subscriptionOne, subscriptionTwo)
        XCTAssertEqual(subscriptionOne.notifications, [.finalResults])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_delete() {
        let model = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscription = Subscription.insert(model, in: persistentContainer.viewContext)

        persistentContainer.viewContext.delete(subscription)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_toRemoteModel() {
        let model = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscription = Subscription.insert(model, in: persistentContainer.viewContext)
        XCTAssertEqual(model, subscription.toRemoteModel())
    }

    func test_isOrphaned() {
        let subscription = Subscription.init(entity: Subscription.entity(), insertInto: persistentContainer.viewContext)
        // Subscription should never be orphaned
        XCTAssertFalse(subscription.isOrphaned)
    }

}
