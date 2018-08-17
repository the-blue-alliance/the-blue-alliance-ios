import Foundation
import CoreData
import TBAKit

extension Subscription: MyTBAManaged {

    var notifications: [NotificationType] {
        get {
            return notificationsRaw?.compactMap({ NotificationType(rawValue: $0) }) ?? []
        }
        set {
            notificationsRaw = newValue.map({ $0.rawValue })
        }
    }

    static func subscriptionPredicate(modelKey: String, modelType: MyTBAModelType) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@",
                           #keyPath(Subscription.modelKey),
                           modelKey,
                           #keyPath(Subscription.modelType),
                           modelType.rawValue)
    }

    @discardableResult
    static func insert(with model: MyTBASubscription, in context: NSManagedObjectContext) -> Subscription {
        return insert(modelKey: model.modelKey, modelType: model.modelType, notifications: model.notifications, in: context)
    }

    @discardableResult
    static func insert(modelKey: String, modelType: MyTBAModelType, notifications: [NotificationType], in context: NSManagedObjectContext) -> Subscription {
        let predicate = subscriptionPredicate(modelKey: modelKey, modelType: modelType)
        return findOrCreate(in: context, matching: predicate) { (subscription) in
            // Required: key, type, notifications
            subscription.modelKey = modelKey
            subscription.modelType = modelType.rawValue
            subscription.notificationsRaw = notifications.map({ $0.rawValue })
        }
    }

    func toRemoteModel() -> MyTBASubscription {
        return MyTBASubscription(modelKey: modelKey!, modelType: MyTBAModelType(rawValue: modelType!)!, notifications: notifications)
    }

}
