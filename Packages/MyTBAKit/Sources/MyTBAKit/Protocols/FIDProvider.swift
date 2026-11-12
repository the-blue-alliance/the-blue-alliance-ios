public protocol FIDProvider: AnyObject {
    /// The Firebase Installation ID FCM delivers this device's notifications to.
    var fid: String? { get }
}
