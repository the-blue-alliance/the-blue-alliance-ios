import Foundation

public enum AuthProviderKind: String, CaseIterable, Sendable {
    case google = "google.com"
    case apple = "apple.com"

    public init?(firebaseProviderID: String) {
        self.init(rawValue: firebaseProviderID)
    }
}
