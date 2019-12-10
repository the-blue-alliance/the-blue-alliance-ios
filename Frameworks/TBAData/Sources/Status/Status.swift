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
