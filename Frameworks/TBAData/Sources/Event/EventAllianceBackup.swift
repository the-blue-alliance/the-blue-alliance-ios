import CoreData
import Foundation
import TBAKit

@objc(EventAllianceBackup)
public class EventAllianceBackup: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventAllianceBackup> {
        return NSFetchRequest<EventAllianceBackup>(entityName: "EventAllianceBackup")
    }

    var alliances: [EventAlliance] {
        guard let alliancesMany = alliancesMany, let alliances = alliancesMany.allObjects as? [EventAlliance] else {
            return []
        }
        return alliances
    }

    var inTeam: Team {
        guard let inTeam = inTeamOne else {
            fatalError("Save EventAllianceBackup before accessing inTeam")
        }
        return inTeam
    }

    var outTeam: Team {
        guard let outTeam = outTeamOne else {
            fatalError("Save EventAllianceBackup before accessing outTeam")
        }
        return outTeam
    }

    @NSManaged private var alliancesMany: NSSet?
    @NSManaged public internal(set) var allianceStatus: EventStatusAlliance?
    @NSManaged private var inTeamOne: Team?
    @NSManaged private var outTeamOne: Team?

}

// MARK: Generated accessors for alliancesMany
extension EventAllianceBackup {

    @objc(removeAlliancesManyObject:)
    @NSManaged internal func removeFromAlliancesMany(_ value: EventAlliance)

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
                                    #keyPath(EventAllianceBackup.inTeamOne.keyString), model.teamIn,
                                    #keyPath(EventAllianceBackup.outTeamOne.keyString), model.teamOut)

        return findOrCreate(in: context, matching: predicate, configure: { (allianceBackup) in
            allianceBackup.inTeamOne = Team.insert(model.teamIn, in: context)
            allianceBackup.outTeamOne = Team.insert(model.teamOut, in: context)
        })
    }

}

extension EventAllianceBackup: Orphanable {

    public var isOrphaned: Bool {
        // An EventAllianceBackup is an orphan if it isn't attached to any EventAlliances or an EventAllianceStatus.
        let hasAlliances = (alliances.count > 0)
        let hasStatus = (allianceStatus != nil)
        return !hasAlliances && !hasStatus
    }

}
