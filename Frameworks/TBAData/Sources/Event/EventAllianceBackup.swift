import CoreData
import Foundation
import TBAKit

@objc(EventAllianceBackup)
public class EventAllianceBackup: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventAllianceBackup> {
        return NSFetchRequest<EventAllianceBackup>(entityName: "EventAllianceBackup")
    }

    @NSManaged public fileprivate(set) var alliances: NSSet?
    @NSManaged public internal(set) var allianceStatus: EventStatusAlliance?
    @NSManaged public fileprivate(set) var inTeam: Team
    @NSManaged public fileprivate(set) var outTeam: Team

}

// MARK: Generated accessors for alliances
extension EventAllianceBackup {

    @objc(addAlliancesObject:)
    @NSManaged private func addToAlliances(_ value: EventAlliance)

    @objc(removeAlliancesObject:)
    @NSManaged internal func removeFromAlliances(_ value: EventAlliance)

    @objc(addAlliances:)
    @NSManaged private func addToAlliances(_ values: NSSet)

    @objc(removeAlliances:)
    @NSManaged private func removeFromAlliances(_ values: NSSet)

}

extension EventAllianceBackup: Managed {

    /**
     Insert a Event Alliance Backup with values from a TBAKit Alliance Backup model in to the managed object context.

     - Important: This method does not manage setting up an Event Alliance Backup relationship to an Event Alliance or an Event Status.

     - Parameter model: The TBAKit Alliance Backup representation to set values from.

     - Parameter context: The NSManagedContext to insert the Event Alliance Backup in to.

     - Returns: The inserted Event Alliance Backup.
     */
    public static func insert(_ model: TBAAllianceBackup, in context: NSManagedObjectContext) -> EventAllianceBackup {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventAllianceBackup.inTeam.keyString), model.teamIn,
                                    #keyPath(EventAllianceBackup.outTeam.keyString), model.teamOut)

        return findOrCreate(in: context, matching: predicate, configure: { (allianceBackup) in
            allianceBackup.inTeam = Team.insert(model.teamIn, in: context)
            allianceBackup.outTeam = Team.insert(model.teamOut, in: context)
        })
    }

}

extension EventAllianceBackup: Orphanable {

    public var isOrphaned: Bool {
        // An EventAllianceBackup is an orphan if it isn't attached to any EventAlliances or an EventAllianceStatus.
        var hasAlliances: Bool {
            guard let alliances = alliances else {
                return false
            }
            return alliances.count > 0
        }
        let hasStatus = (allianceStatus != nil)
        return !hasAlliances && !hasStatus
    }

}
