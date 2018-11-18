import Foundation
import CoreData

extension EventAllianceBackup: Managed {

    /**
     Insert a Event Alliance Backup with values from a TBAKit Alliance Backup model in to the managed object context.

     - Important: This method does not manage setting up an Event Alliance Backup relationship to an Event Alliance or an Event Status.

     - Parameter model: The TBAKit Alliance Backup representation to set values from.

     - Parameter context: The NSManagedContext to insert the Event Alliance Backup in to.

     - Returns: The inserted Event Alliance Backup.
     */
    static func insert(_ model: TBAAllianceBackup, in context: NSManagedObjectContext) -> EventAllianceBackup {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventAllianceBackup.inTeam.key), model.teamIn,
                                    #keyPath(EventAllianceBackup.outTeam.key), model.teamOut)

        return findOrCreate(in: context, matching: predicate, configure: { (allianceBackup) in
            allianceBackup.inTeam = TeamKey.insert(withKey: model.teamIn, in: context)
            allianceBackup.outTeam = TeamKey.insert(withKey: model.teamOut, in: context)
        })
    }

    var isOrphaned: Bool {
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
