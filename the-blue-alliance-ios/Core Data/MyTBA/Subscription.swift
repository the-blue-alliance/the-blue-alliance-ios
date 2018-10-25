import CoreData
import Foundation
import TBAKit

extension Subscription: MyTBAManaged {

    /**
     Insert a Subscription with values from a MyTBA Subscription model in to the managed object context.

     - Parameter model: The MyTBA Subscription representation to set values from.

     - Parameter context: The NSManagedContext to insert the Favorite in to.

     - Returns: The inserted Subscription.
     */
    @discardableResult
    static func insert(_ model: MyTBASubscription, in context: NSManagedObjectContext) -> Subscription {
        let predicate = NSPredicate(format: "%K == %@ && %K == %@",
                                    #keyPath(Subscription.modelKey), model.modelKey,
                                    #keyPath(Subscription.modelType), model.modelType.rawValue)

        return findOrCreate(in: context, matching: predicate) { (subscription) in
            // Required: key, type, notifications
            subscription.modelKey = model.modelKey
            subscription.modelType = model.modelType.rawValue
            subscription.notifications = model.notifications.map({ $0.rawValue })
        }
    }

    func toRemoteModel() -> MyTBASubscription {
        return MyTBASubscription(modelKey: modelKey!, modelType: MyTBAModelType(rawValue: modelType!)!, notifications: notifications!.map({ NotificationType(rawValue: $0)! }))
    }

}
