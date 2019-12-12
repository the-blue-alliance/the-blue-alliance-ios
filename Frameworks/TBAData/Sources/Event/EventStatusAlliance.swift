import CoreData
import Foundation
import TBAKit

@objc(EventStatusAlliance)
public class EventStatusAlliance: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusAlliance> {
        return NSFetchRequest<EventStatusAlliance>(entityName: "EventStatusAlliance")
    }

    @NSManaged public fileprivate(set) var name: String?
    @NSManaged public fileprivate(set) var number: Int16
    @NSManaged public fileprivate(set) var pick: Int16
    @NSManaged public fileprivate(set) var backup: EventAllianceBackup?
    @NSManaged public fileprivate(set) var eventStatus: EventStatus

}

extension EventStatusAlliance: Managed {

    public static func insert(_ model: TBAEventStatusAlliance, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusAlliance {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventStatusAlliance.eventStatus.event.key), eventKey,
                                    #keyPath(EventStatusAlliance.eventStatus.team.key), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (allianceStatus) in
            allianceStatus.number = Int16(model.number)
            allianceStatus.pick = Int16(model.pick)
            allianceStatus.name = model.name

            allianceStatus.updateToOneRelationship(relationship: #keyPath(EventStatusAlliance.backup), newValue: model.backup, newObject: {
                return EventAllianceBackup.insert($0, in: context)
            })
        })
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

extension EventStatusAlliance: Orphanable {

    public var isOrphaned: Bool {
        return eventStatus == nil
    }

}
