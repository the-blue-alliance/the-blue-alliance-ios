import Foundation

struct AppSettings {

    let cachePolicy: CachePolicyStore

    init(defaults: UserDefaults = .standard) {
        self.cachePolicy = CachePolicyStore(defaults: defaults)
    }
}
