//
//  TBAStatus.swift
//  Pods
//
//  Created by Zach Orr on 1/7/17.
//
//

import UIKit

public struct TBAStatus: TBAModel {
    public var android: TBAAppInfo
    public var ios: TBAAppInfo
    public var currentSeason: UInt
    public var downEvents: [String]
    public var datafeedDown: Bool
    public var maxSeason: UInt

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

        guard let currentSeason = json["current_season"] as? UInt else {
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

        guard let maxSeason = json["max_season"] as? UInt else {
            return nil
        }
        self.maxSeason = maxSeason
    }

}

public struct TBAAppInfo: TBAModel {
    
    public var latestAppVersion: Int
    public var minAppVersion: Int

    init?(json: [String: Any]) {
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

    public func fetchStatus(_ completion: @escaping (_ status: TBAStatus?, _ error: Error?) -> ()) -> URLSessionDataTask {
        let method = "status"
        return callObject(method: method, completion: completion)
    }

}
