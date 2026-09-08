import Foundation
import TBAAPI

struct CachePolicyStore {

    private static let key = "kTBACachePolicy"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var current: TBAAPI.CachePolicy {
        get {
            guard let raw = defaults.string(forKey: Self.key),
                let policy = TBAAPI.CachePolicy(rawValue: raw)
            else {
                return .default
            }
            return policy
        }
        nonmutating set {
            defaults.set(newValue.rawValue, forKey: Self.key)
        }
    }
}
