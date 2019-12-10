import CoreData
import Foundation
import MyTBAKit

extension Subscription {

    internal static func subscriptionPredicate(modelKey: String, modelType: MyTBAModelType) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %ld",
                           #keyPath(Subscription.modelKey), modelKey,
                           #keyPath(Subscription.modelTypeRaw), modelType.rawValue)
    }

    /**
     Insert Subscriptions with values from myTBA Subscription models in to the managed object context.

     This method manages deleting old Subscriptions.

     - Parameter subscriptions: The myTBA Subscription representations to set values from.

     - Parameter context: The NSManagedContext to insert the Subscription in to.

     - Returns: The array of inserted Subscriptions.
     */
    @discardableResult
    public static func insert(_ subscriptions: [MyTBASubscription], in context: NSManagedObjectContext) -> [Subscription] {
        // Fetch all of the previous Subscriptions
        let oldSubscriptions = Subscription.fetch(in: context)

        // Insert new Subscriptions
        let subscriptions = subscriptions.map({
            return Subscription.insert($0, in: context)
        })

        // Delete orphaned Subscriptions
        Set(oldSubscriptions).subtracting(Set(subscriptions)).forEach({
            context.delete($0)
        })

        return subscriptions
    }

    /**
     Insert a Subscription with values from a myTBA Subscription model in to the managed object context.

     - Parameter model: The myTBA Subscription representation to set values from.

     - Parameter context: The NSManagedContext to insert the Subscription in to.

     - Returns: The inserted Subscription.
     */
    @discardableResult
    public static func insert(_ model: MyTBASubscription, in context: NSManagedObjectContext) -> Subscription {
        return insert(modelKey: model.modelKey, modelType: model.modelType, notifications: model.notifications, in: context)
    }

    public static func fetch(modelKey: String, modelType: MyTBAModelType, in context: NSManagedObjectContext) -> Subscription? {
        let predicate = subscriptionPredicate(modelKey: modelKey, modelType: modelType)
        return findOrFetch(in: context, matching: predicate)
    }

}

extension Subscription: MyTBAManaged {

    public func toRemoteModel() -> MyTBASubscription {
        return MyTBASubscription(modelKey: modelKey, modelType: modelType, notifications: notifications)
    }

}
