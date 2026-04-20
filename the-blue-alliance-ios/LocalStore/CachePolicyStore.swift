import Foundation
import TBAAPI

private let kTBACachePolicy = "kTBACachePolicy"

struct CachePolicyStore {

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var current: TBAAPI.CachePolicy {
        get {
            guard let raw = defaults.string(forKey: kTBACachePolicy),
                let policy = TBAAPI.CachePolicy(rawValue: raw)
            else {
                return .default
            }
            return policy
        }
        nonmutating set {
            defaults.set(newValue.rawValue, forKey: kTBACachePolicy)
        }
    }
}
