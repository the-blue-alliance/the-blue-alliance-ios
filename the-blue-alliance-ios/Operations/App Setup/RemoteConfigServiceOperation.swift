import Crashlytics
import FirebaseRemoteConfig
import Foundation

class RemoteConfigServiceOperation: TBAOperation {

    var remoteConfigService: RemoteConfigService

    init(remoteConfigService: RemoteConfigService) {
        self.remoteConfigService = remoteConfigService

        super.init()
    }

    override func execute() {
        self.remoteConfigService.fetchRemoteConfig { (error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
            self.finish()
        }
    }

}
