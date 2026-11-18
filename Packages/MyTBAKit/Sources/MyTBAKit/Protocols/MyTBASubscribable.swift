import Foundation

// Models that can be favorited or subscribed to via myTBA.
public protocol MyTBASubscribable: MyTBAModelIdentifiable {
    var modelKey: String { get }
    var modelType: MyTBAModelType { get }
    static var notificationTypes: [NotificationType] { get }
}

extension MyTBASubscribable {
    public var myTBAModelID: MyTBAModelID {
        MyTBAModelID(modelType: modelType, modelKey: modelKey)
    }
}
