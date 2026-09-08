import Foundation

// Models that can be favorited or subscribed to via myTBA.
public protocol MyTBASubscribable {
    var modelKey: String { get }
    var modelType: MyTBAModelType { get }
    static var notificationTypes: [NotificationType] { get }
}
