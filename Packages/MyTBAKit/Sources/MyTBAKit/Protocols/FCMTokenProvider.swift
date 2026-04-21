public protocol FCMTokenProvider: AnyObject, Sendable {
    var fcmToken: String? { get }
}
