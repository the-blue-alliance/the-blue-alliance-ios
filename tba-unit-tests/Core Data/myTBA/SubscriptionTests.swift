import Foundation
import XCTest
@testable import The_Blue_Alliance

class SubscriptionTestCase: CoreDataTestCase {

    func test_insert() {
        let model = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscription = Subscription.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(subscription.modelKey, "2018miket")
        XCTAssertEqual(subscription.modelType, "0")
        XCTAssertEqual(subscription.notifications, ["awards_posted"])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let modelOne = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards])
        let subscriptionOne = Subscription.insert(modelOne, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(subscriptionOne.notifications, ["awards_posted"])

        let modelTwo = MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.finalResults])
        let subscriptionTwo = Subscription.insert(modelTwo, in: persistentContainer.viewContext)

        XCTAssertEqual(subscriptionOne, subscriptionTwo)
        XCTAssertEqual(subscriptionTwo.notifications, ["final_results"])

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
