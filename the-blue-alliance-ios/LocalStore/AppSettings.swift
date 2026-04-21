import Foundation

struct AppSettings {

    let cachePolicy: CachePolicyStore
    let firebaseCollection: FirebaseCollectionStore

    init(defaults: UserDefaults = .standard) {
        self.cachePolicy = CachePolicyStore(defaults: defaults)
        self.firebaseCollection = FirebaseCollectionStore(defaults: defaults)
    }
}
