import CoreData
import Foundation
import MyTBAKit

@objc(Subscription)
public class Subscription: MyTBAEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subscription> {
        return NSFetchRequest<Subscription>(entityName: "Subscription")
    }

    @NSManaged public var notificationsRaw: [String]?

}

extension Subscription {

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

    @discardableResult
    public static func insert(modelKey: String, modelType: MyTBAModelType, notifications: [NotificationType], in context: NSManagedObjectContext) -> Subscription {
        let predicate = subscriptionPredicate(modelKey: modelKey, modelType: modelType)

        return findOrCreate(in: context, matching: predicate) { (subscription) in
            // Required: key, type, notifications
            subscription.modelKeyString = modelKey
            subscription.modelTypeNumber = NSNumber(value: modelType.rawValue)
            subscription.notificationsRaw = notifications.map({ $0.rawValue })
        }
    }

}

extension Subscription {

    public var notifications: [NotificationType] {
        get {
            return notificationsRaw?.compactMap({ NotificationType(rawValue: $0) }) ?? []
        }
        set {
            notificationsRaw = newValue.map({ $0.rawValue })
        }
    }

    fileprivate static func subscriptionPredicate(modelKey: String, modelType: MyTBAModelType) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %ld",
                           #keyPath(Subscription.modelKeyString), modelKey,
                           #keyPath(Subscription.modelTypeNumber), modelType.rawValue)
    }

    public static func fetch(modelKey: String, modelType: MyTBAModelType, in context: NSManagedObjectContext) -> Subscription? {
        let predicate = subscriptionPredicate(modelKey: modelKey, modelType: modelType)
        return findOrFetch(in: context, matching: predicate)
    }

}

extension Subscription: MyTBAManaged {}
