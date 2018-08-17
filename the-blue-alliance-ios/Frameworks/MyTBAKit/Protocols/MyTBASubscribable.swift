import Foundation

// Core Data objects that can be subscribed via myTBA conform to MyTBASubscribable
protocol MyTBASubscribable {
    static var notificationTypes: [NotificationType] { get }
}
