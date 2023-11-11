public protocol FCMTokenProvider: AnyObject {
    var fcmToken: String? { get }
}
