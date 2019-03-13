import CoreData
import Foundation
import TBAKit

extension EventStatusAlliance: Managed {

    static func insert(_ model: TBAEventStatusAlliance, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusAlliance {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventStatusAlliance.eventStatus.event.key), eventKey,
                                    #keyPath(EventStatusAlliance.eventStatus.teamKey.key), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (allianceStatus) in
            allianceStatus.number = model.number as NSNumber
            allianceStatus.pick = model.pick as NSNumber
            allianceStatus.name = model.name

            allianceStatus.updateToOneRelationship(relationship: #keyPath(EventStatusAlliance.backup), newValue: model.backup, newObject: {
                return EventAllianceBackup.insert($0, in: context)
            })
        })
    }

    var isOrphaned: Bool {
        return eventStatus == nil
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        if let backup = backup {
            if backup.alliances?.count == 0 && backup.allianceStatus == self {
                // AllianceBackup will become an orphan - delete
                managedObjectContext?.delete(backup)
            } else {
                backup.allianceStatus = nil
            }
        }
    }

}
