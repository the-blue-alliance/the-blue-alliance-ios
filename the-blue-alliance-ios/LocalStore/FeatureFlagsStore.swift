import Foundation

enum FeatureFlag: String, CaseIterable {
    case dashboard

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        }
    }

    var requiresRelaunch: Bool {
        switch self {
        case .dashboard: return true
        }
    }
}

struct FeatureFlagsStore {

    private static let keyPrefix = "kTBAFeatureFlag."

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isEnabled(_ flag: FeatureFlag) -> Bool {
        defaults.bool(forKey: Self.key(for: flag))
    }

    func setEnabled(_ enabled: Bool, for flag: FeatureFlag) {
        defaults.set(enabled, forKey: Self.key(for: flag))
    }

    func pruneRetiredFlags() {
        let live = Set(FeatureFlag.allCases.map(Self.key(for:)))
        for key in defaults.dictionaryRepresentation().keys
        where key.hasPrefix(Self.keyPrefix) && !live.contains(key) {
            defaults.removeObject(forKey: key)
        }
    }

    private static func key(for flag: FeatureFlag) -> String {
        keyPrefix + flag.rawValue
    }
}
