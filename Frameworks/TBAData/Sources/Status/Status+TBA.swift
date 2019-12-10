import CoreData
import Foundation
import TBAKit

extension Status {

    internal static var statusPredicate: NSPredicate {
        return NSPredicate(value: true)
    }

    /**
     'Singleton' to get the only Status that should exist in the context
     */
    public static func status(in context: NSManagedObjectContext) -> Status? {
        return findOrFetch(in: context, matching: statusPredicate)
    }

    public static func fromPlist(bundle: Bundle, in context: NSManagedObjectContext) -> Status? {
        guard let path = bundle.path(forResource: "StatusDefaults", ofType: "plist") else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        guard let result = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: Any] else {
            return nil
        }

        let latestAppVersion = result["latest_app_version"] as? Int ?? -1
        let minAppVersion = result["min_app_version"] as? Int ?? -1
        guard let currentSeason = result["current_season"] as? Int else {
            return nil
        }
        guard let maxSeason = result["max_season"] as? Int else {
            return nil
        }

        let localStatus = TBAStatus(android: TBAAppInfo(latestAppVersion: -1, minAppVersion: -1),
                                    ios: TBAAppInfo(latestAppVersion: latestAppVersion, minAppVersion: minAppVersion),
                                    currentSeason: currentSeason,
                                    downEvents: [],
                                    datafeedDown: false,
                                    maxSeason: maxSeason)
        return insert(localStatus, in: context)
    }

}

extension Status: Managed {

    public var isOrphaned: Bool {
        return false
    }

}
