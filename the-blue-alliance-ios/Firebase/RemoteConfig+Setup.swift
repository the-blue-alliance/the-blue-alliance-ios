import Foundation
import Firebase

extension RemoteConfig {

    /*
    public enum Keys: String {
    }
    */

    static func setupRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        #if DEBUG
        if let configSettings = RemoteConfigSettings(developerModeEnabled: true) {
            remoteConfig.configSettings = configSettings
        }
        #endif
        
        remoteConfig.fetch { (status, error) in
            if let error = error {
                print("Unable to fetch remote configuration for Firebase: \(error)")
            } else if status == .success {
                remoteConfig.activateFetched()
            }
        }

    }

}
