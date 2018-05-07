import Foundation
import CoreData
import TBAKit

extension Subscription: MyTBAManaged {

    static func insert(with model: MyTBASubscription, in context: NSManagedObjectContext) -> Subscription {
        let predicate = NSPredicate(format: "modelKey == %@ && modelType == %@", model.modelKey, model.modelType.rawValue)
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
