import CoreData
import Foundation
import TBAKit

extension EventAllianceBackup {

    public var alliances: [EventAlliance] {
        guard let alliancesRaw = getValue(\EventAllianceBackup.alliancesRaw),
            let alliances = alliancesRaw.allObjects as? [EventAlliance] else {
                return []
        }
        return alliances
    }

    public var allianceStatus: EventStatusAlliance? {
        return getValue(\EventAllianceBackup.allianceStatusRaw)
    }

    public var inTeam: Team {
        guard let inTeam = getValue(\EventAllianceBackup.inTeamRaw) else {
            fatalError("Save EventAllianceBackup before accessing inTeam")
        }
        return inTeam
    }

    public var outTeam: Team {
        guard let outTeam = getValue(\EventAllianceBackup.outTeamRaw) else {
            fatalError("Save EventAllianceBackup before accessing outTeam")
        }
        return outTeam
    }

}

@objc(EventAllianceBackup)
public class EventAllianceBackup: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventAllianceBackup> {
        return NSFetchRequest<EventAllianceBackup>(entityName: EventAllianceBackup.entityName)
    }

    @NSManaged var alliancesRaw: NSSet?
    @NSManaged var allianceStatusRaw: EventStatusAlliance?
    @NSManaged var inTeamRaw: Team?
    @NSManaged var outTeamRaw: Team?

}

// MARK: Generated accessors for alliancesRaw
extension EventAllianceBackup {

    @objc(addAlliancesRawObject:)
    @NSManaged func addToAlliancesRaw(_ value: EventAlliance)

    @objc(removeAlliancesRawObject:)
    @NSManaged func removeFromAlliancesRaw(_ value: EventAlliance)

    @objc(addAlliancesRaw:)
    @NSManaged func addToAlliancesRaw(_ values: NSSet)

    @objc(removeAlliancesRaw:)
    @NSManaged func removeFromAlliancesRaw(_ values: NSSet)

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
                                    #keyPath(EventAllianceBackup.inTeamRaw.keyRaw), model.teamIn,
                                    #keyPath(EventAllianceBackup.outTeamRaw.keyRaw), model.teamOut)

        return findOrCreate(in: context, matching: predicate, configure: { (allianceBackup) in
            allianceBackup.inTeamRaw = Team.insert(model.teamIn, in: context)
            allianceBackup.outTeamRaw = Team.insert(model.teamOut, in: context)
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
