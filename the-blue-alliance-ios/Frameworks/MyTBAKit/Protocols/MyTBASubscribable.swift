import Foundation

// Core Data objects that can be subscribed via myTBA conform to MyTBASubscribable
protocol MyTBASubscribable {
    var modelKey: String { get }
    var modelType: MyTBAModelType { get }

    static var notificationTypes: [NotificationType] { get }
}
