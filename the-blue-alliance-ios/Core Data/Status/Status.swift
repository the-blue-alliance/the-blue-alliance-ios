import CoreData
import Foundation
import TBAKit

extension Status: Managed {

    /**
     'Singleton' to get the only Status that should exist in the context
     */
    static func status(in context: NSManagedObjectContext) -> Status? {
        return findOrFetch(in: context, matching: statusPredicate)
    }

    private static var statusPredicate: NSPredicate {
        return NSPredicate(value: true)
    }

    /**
     Insert an Status with values from a TBAKit Status model in to the managed object context.

     - Parameter model: The TBAKit Status representation to set values from.

     - Parameter context: The NSManagedContext to insert the Award in to.

     - Returns: The inserted Status.
     */
    @discardableResult
    static func insert(_ model: TBAStatus, in context: NSManagedObjectContext) -> Status {
        return findOrCreate(in: context, matching: statusPredicate) { (status) in
            status.currentSeason = model.currentSeason as NSNumber

            status.updateToManyRelationship(relationship: #keyPath(Status.downEvents), newValues: model.downEvents.map({
                return EventKey.insert(withKey: $0, in: context)
            }))

            status.latestAppVersion = model.ios.latestAppVersion as NSNumber
            status.minAppVersion = model.ios.minAppVersion as NSNumber
            status.isDatafeedDown = model.datafeedDown as NSNumber
            status.maxSeason = model.maxSeason as NSNumber
        }
    }

    static func fromPlist(bundle: Bundle, in context: NSManagedObjectContext) -> Status? {
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

    var isOrphaned: Bool {
        return false
    }

    var safeMinAppVersion: Int {
        let minAppVersion = getValue(\Status.minAppVersion?.intValue)
        return minAppVersion ?? -1
    }

}
