import CoreData
import Foundation
import MyTBAKit

@objc(Subscription)
public class Subscription: MyTBAEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subscription> {
        return NSFetchRequest<Subscription>(entityName: "Subscription")
    }

    @NSManaged fileprivate var notificationsRaw: [String]

}

extension Subscription {

    public var notifications: [NotificationType] {
        get {
            return notificationsRaw.compactMap({ NotificationType(rawValue: $0) }) ?? []
        }
        set {
            notificationsRaw = newValue.map({ $0.rawValue })
        }
    }

    @discardableResult
    public static func insert(modelKey: String, modelType: MyTBAModelType, notifications: [NotificationType], in context: NSManagedObjectContext) -> Subscription {
        let predicate = subscriptionPredicate(modelKey: modelKey, modelType: modelType)

        return findOrCreate(in: context, matching: predicate) { (subscription) in
            // Required: key, type, notifications
            subscription.modelKey = modelKey
            subscription.modelType = modelType
            subscription.notificationsRaw = notifications.map({ $0.rawValue })
        }
    }

}
