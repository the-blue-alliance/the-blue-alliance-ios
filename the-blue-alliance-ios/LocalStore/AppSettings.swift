import Foundation

struct AppSettings {

    let cachePolicy: CachePolicyStore
    let featureFlags: FeatureFlagsStore
    let firebaseCollection: FirebaseCollectionStore

    init(defaults: UserDefaults = .standard) {
        self.cachePolicy = CachePolicyStore(defaults: defaults)
        self.featureFlags = FeatureFlagsStore(defaults: defaults)
        self.firebaseCollection = FirebaseCollectionStore(defaults: defaults)
    }
}
