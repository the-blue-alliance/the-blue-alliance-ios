import Foundation

struct FirebaseCollectionStore {

    private static let analyticsKey = "kAnalyticsCollectionEnabled"
    private static let crashlyticsKey = "kCrashlyticsCollectionEnabled"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var analyticsEnabled: Bool {
        get { enabled(forKey: Self.analyticsKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.analyticsKey) }
    }

    var crashlyticsEnabled: Bool {
        get { enabled(forKey: Self.crashlyticsKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.crashlyticsKey) }
    }

    private func enabled(forKey key: String) -> Bool {
        defaults.object(forKey: key) as? Bool ?? true
    }
}
