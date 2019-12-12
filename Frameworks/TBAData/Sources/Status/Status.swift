import CoreData
import Foundation
import TBAKit

@objc(Status)
public class Status: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Status> {
        return NSFetchRequest<Status>(entityName: "Status")
    }

    @NSManaged public fileprivate(set) var currentSeason: Int16
    @NSManaged public fileprivate(set) var isDatafeedDown: Bool
    @NSManaged public fileprivate(set) var latestAppVersion: Int64
    @NSManaged public fileprivate(set) var maxSeason: Int16
    @NSManaged public fileprivate(set) var minAppVersion: Int64
    @NSManaged public fileprivate(set) var downEvents: NSSet

}

extension Status {

    /**
     Insert an Status with values from a TBAKit Status model in to the managed object context.

     - Parameter model: The TBAKit Status representation to set values from.

     - Parameter context: The NSManagedContext to insert the Award in to.

     - Returns: The inserted Status.
     */
    @discardableResult
    public static func insert(_ model: TBAStatus, in context: NSManagedObjectContext) -> Status {
        return findOrCreate(in: context, matching: statusPredicate) { (status) in
            status.currentSeason = Int16(model.currentSeason)

            status.updateToManyRelationship(relationship: #keyPath(Status.downEvents), newValues: model.downEvents.map {
                return Event.insert($0, in: context)
            })

            status.latestAppVersion = Int64(model.ios.latestAppVersion)
            status.minAppVersion = Int64(model.ios.minAppVersion)
            status.isDatafeedDown = model.datafeedDown
            status.maxSeason = Int16(model.maxSeason)
        }
    }

}

extension Status {

    fileprivate static var statusPredicate: NSPredicate {
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
