import Foundation

struct MyTBAPreferences {

    var deviceKey: String
    var favorite: Bool
    var modelKey: String
    var modelType: Int
    var notifications: [NotificationType]

}

extension MyTBA {

    // TODO: Android has some local rate limiting, which is probably smart
    // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/174
}
