import Crashlytics
import FirebaseRemoteConfig
import Foundation

class RemoteConfigService {

    private var remoteConfig: RemoteConfig
    internal var retryService: RetryService

    init(remoteConfig: RemoteConfig, retryService: RetryService) {
        self.remoteConfig = remoteConfig
        #if DEBUG
        if let configSettings = RemoteConfigSettings(developerModeEnabled: true) {
            self.remoteConfig.configSettings = configSettings
        }
        #endif
        self.retryService = retryService

        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }

    internal func fetchRemoteConfig(completion: ((_ error: Error?) -> Void)? = nil) {
        remoteConfig.fetch(withExpirationDuration: retryInterval) { (remoteConfigStatus, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
            self.remoteConfig.activateFetched()

            if let completion = completion {
                completion(error)
            }
        }
    }

}

extension RemoteConfigService: Retryable {

    var retryInterval: TimeInterval {
        // Poll every... 5 mins for a new config
        return 10 * 60
    }

    func retry() {
        fetchRemoteConfig()
    }

}
