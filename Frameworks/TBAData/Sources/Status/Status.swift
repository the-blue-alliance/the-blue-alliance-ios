import CoreData
import Foundation
import TBAKit

@objc(Status)
public class Status: NSManagedObject {

    public var currentSeason: Int {
        guard let currentSeason = currentSeasonNumber?.intValue else {
            fatalError("Save Status before accessing currentSeason")
        }
        return currentSeason
    }

    public var isDatafeedDown: Bool {
        guard let isDatafeedDown = isDatafeedDownNumber?.boolValue else {
            fatalError("Save Status before accessing isDatafeedDown")
        }
        return isDatafeedDown
    }

    public var latestAppVersion: Int {
        guard let latestAppVersion = latestAppVersionNumber?.intValue else {
            fatalError("Save Status before accessing latestAppVersion")
        }
        return latestAppVersion
    }

    public var maxSeason: Int {
        guard let maxSeason = maxSeasonNumber?.intValue else {
            fatalError("Save Status before accessing maxSeason")
        }
        return maxSeason
    }

    public var minAppVersion: Int {
        guard let minAppVersion = minAppVersionNumber?.intValue else {
            fatalError("Save Status before accessing minAppVersion")
        }
        return minAppVersion
    }

    public var downEvents: [Event] {
        guard let downEventsMany = downEventsMany, let downEvents = downEventsMany.allObjects as? [Event] else {
            return []
        }
        return downEvents
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Status> {
        return NSFetchRequest<Status>(entityName: Status.entityName)
    }

    @NSManaged private var currentSeasonNumber: NSNumber?
    @NSManaged private var isDatafeedDownNumber: NSNumber?
    @NSManaged private var latestAppVersionNumber: NSNumber?
    @NSManaged private var maxSeasonNumber: NSNumber?
    @NSManaged private var minAppVersionNumber: NSNumber?
    @NSManaged private var downEventsMany: NSSet?

}

extension Status: Managed {

    /**
     Insert an Status with values from a TBAKit Status model in to the managed object context.

     - Parameter model: The TBAKit Status representation to set values from.

     - Parameter context: The NSManagedContext to insert the Award in to.

     - Returns: The inserted Status.
     */
    @discardableResult
    public static func insert(_ model: TBAStatus, in context: NSManagedObjectContext) -> Status {
        return findOrCreate(in: context, matching: statusPredicate) { (status) in
            status.currentSeasonNumber = NSNumber(value: model.currentSeason)
            status.downEventsMany = NSSet(array: model.downEvents.map {
                return Event.insert($0, in: context)
            })
            status.latestAppVersionNumber = NSNumber(value: model.ios.latestAppVersion)
            status.minAppVersionNumber = NSNumber(value: model.ios.minAppVersion)
            status.isDatafeedDownNumber = NSNumber(value: model.datafeedDown)
            status.maxSeasonNumber = NSNumber(value: model.maxSeason)
        }
    }

}

extension Status {

    private static var statusPredicate: NSPredicate {
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
