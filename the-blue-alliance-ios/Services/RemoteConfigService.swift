import Crashlytics
import FirebaseRemoteConfig
import Foundation
import TBAUtils

protocol RemoteConfigObservable {
    func remoteConfigUpdated()
}

class RemoteConfigService {

    var remoteConfig: RemoteConfig
    var retryService: RetryService

    public var remoteConfigProvider = Provider<RemoteConfigObservable>()

    init(remoteConfig: RemoteConfig, retryService: RetryService) {
        self.remoteConfig = remoteConfig
        self.retryService = retryService

        // Allow remote config fetching frequently
        #if DEBUG
        let configSettings = RemoteConfigSettings()
        configSettings.minimumFetchInterval = 0
        remoteConfig.configSettings = configSettings
        #endif

        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }

    internal func fetchRemoteConfig(completion: ((_ error: Error?) -> Void)? = nil) {
        remoteConfig.fetchAndActivate { (remoteConfigStatus, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            } else {
                self.remoteConfigProvider.post {
                    $0.remoteConfigUpdated()
                }
            }
            completion?(error)
        }
    }

}

extension RemoteConfigService: Retryable {

    var retryInterval: TimeInterval {
        // Poll every... 5 mins for a new config
        // Note that this data will only be invalidated every 12 hours - otherwise we hit a cache
        return 5 * 60
    }

    func retry() {
        fetchRemoteConfig()
    }

}
