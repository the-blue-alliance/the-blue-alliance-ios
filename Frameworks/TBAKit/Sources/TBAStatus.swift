import Foundation

public struct TBAStatus: TBAModel {

    public var android: TBAAppInfo
    public var ios: TBAAppInfo
    public var currentSeason: Int
    public var downEvents: [String]
    public var datafeedDown: Bool
    public var maxSeason: Int

    public init(android: TBAAppInfo, ios: TBAAppInfo, currentSeason: Int, downEvents: [String], datafeedDown: Bool, maxSeason: Int) {
        self.android = android
        self.ios = ios
        self.currentSeason = currentSeason
        self.downEvents = downEvents
        self.datafeedDown = datafeedDown
        self.maxSeason = maxSeason
    }

    public init?(json: [String: Any]) {
        guard let androidJSON = json["android"] as? [String: Any] else {
            return nil
        }
        guard let android = TBAAppInfo(json: androidJSON) else {
            return nil
        }
        self.android = android

        guard let iosJSON = json["ios"] as? [String: Any] else {
            return nil
        }
        guard let ios = TBAAppInfo(json: iosJSON) else {
            return nil
        }
        self.ios = ios

        guard let currentSeason = json["current_season"] as? Int else {
            return nil
        }
        self.currentSeason = currentSeason

        guard let downEvents = json["down_events"] as? [String] else {
            return nil
        }
        self.downEvents = downEvents

        guard let datafeedDown = json["is_datafeed_down"] as? Bool else {
            return nil
        }
        self.datafeedDown = datafeedDown

        guard let maxSeason = json["max_season"] as? Int else {
            return nil
        }
        self.maxSeason = maxSeason
    }

}

public struct TBAAppInfo: TBAModel, Equatable {
    
    public var latestAppVersion: Int
    public var minAppVersion: Int

    public init(latestAppVersion: Int, minAppVersion: Int) {
        self.latestAppVersion = latestAppVersion
        self.minAppVersion = minAppVersion
    }

    public init?(json: [String: Any]) {
        guard let latestAppVersion = json["latest_app_version"] as? Int else {
            return nil
        }
        self.latestAppVersion = latestAppVersion

        guard let minAppVersion = json["min_app_version"] as? Int else {
            return nil
        }
        self.minAppVersion = minAppVersion
    }

}

extension TBAKit {

    public func fetchStatus(_ completion: @escaping (Result<TBAStatus?, Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "status"
        return callObject(method: method, completion: completion)
    }

}
