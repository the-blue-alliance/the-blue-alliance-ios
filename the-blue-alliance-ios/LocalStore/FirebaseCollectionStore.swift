import Foundation

private let kAnalyticsCollectionEnabled = "kAnalyticsCollectionEnabled"
private let kCrashlyticsCollectionEnabled = "kCrashlyticsCollectionEnabled"

struct FirebaseCollectionStore {

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var analyticsEnabled: Bool {
        get { enabled(forKey: kAnalyticsCollectionEnabled) }
        nonmutating set { defaults.set(newValue, forKey: kAnalyticsCollectionEnabled) }
    }

    var crashlyticsEnabled: Bool {
        get { enabled(forKey: kCrashlyticsCollectionEnabled) }
        nonmutating set { defaults.set(newValue, forKey: kCrashlyticsCollectionEnabled) }
    }

    private func enabled(forKey key: String) -> Bool {
        defaults.object(forKey: key) as? Bool ?? true
    }
}
