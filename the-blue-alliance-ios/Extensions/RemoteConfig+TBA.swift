import Foundation
import FirebaseRemoteConfig

extension RemoteConfig {

    private struct TBARemoteConfigKeys {
        static let currentSeason = "current_season"
        static let latestAppVersion = "ios_latest_app_version"
        static let minimumAppVersion = "ios_min_app_version"
        static let maxSeason = "max_season"
        static let appStoreID = "app_store_id"
    }

    var currentSeason: Int {
        guard let currentSeason = configValue(forKey: TBARemoteConfigKeys.currentSeason).numberValue else {
            assertionFailure("\(TBARemoteConfigKeys.currentSeason) not in RemoteConfigDefaults - fix that")
            return Calendar.current.year
        }
        return currentSeason.intValue
    }

    var latestAppVersion: Int {
        guard let latestAppVersion = configValue(forKey: TBARemoteConfigKeys.latestAppVersion).numberValue else {
            assertionFailure("\(TBARemoteConfigKeys.latestAppVersion) not in RemoteConfigDefaults - fix that")
            return -1
        }
        return latestAppVersion.intValue
    }

    var minimumAppVersion: Int {
        guard let minimumAppVersion = configValue(forKey: TBARemoteConfigKeys.minimumAppVersion).numberValue else {
            assertionFailure("\(TBARemoteConfigKeys.minimumAppVersion) not in RemoteConfigDefaults - fix that")
            return -1
        }
        return minimumAppVersion.intValue
    }

    var maxSeason: Int {
        guard let maxSeason = configValue(forKey: TBARemoteConfigKeys.maxSeason).numberValue else {
            assertionFailure("\(TBARemoteConfigKeys.maxSeason) not in RemoteConfigDefaults - fix that")
            return Calendar.current.year
        }
        return maxSeason.intValue
    }

    var appStoreID: String {
        guard let appStoreID = configValue(forKey: TBARemoteConfigKeys.appStoreID).stringValue else {
            assertionFailure("\(TBARemoteConfigKeys.appStoreID) not in RemoteConfigDefaults - fix that")
            return ""
        }
        return appStoreID
    }

}
