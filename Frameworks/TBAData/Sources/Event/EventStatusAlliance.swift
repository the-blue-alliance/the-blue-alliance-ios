import CoreData
import Foundation
import TBAKit

@objc(EventStatusAlliance)
public class EventStatusAlliance: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusAlliance> {
        return NSFetchRequest<EventStatusAlliance>(entityName: EventStatusAlliance.entityName)
    }

    public var number: Int {
        guard let number = numberNumber?.intValue else {
            fatalError("Save EventStatusAlliance before accessing number")
        }
        return number
    }

    public var pick: Int {
        guard let pick = pickNumber?.intValue else {
            fatalError("Save EventStatusAlliance before accessing pick")
        }
        return pick
    }

    @NSManaged var name: String?
    @NSManaged var numberNumber: NSNumber?
    @NSManaged var pickNumber: NSNumber?
    @NSManaged var backup: EventAllianceBackup?
    @NSManaged var eventStatusOne: EventStatus?

}

extension EventStatusAlliance: Managed {

    public static func insert(_ model: TBAEventStatusAlliance, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusAlliance {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventStatusAlliance.eventStatusOne.eventOne.keyRaw), eventKey,
                                    #keyPath(EventStatusAlliance.eventStatusOne.teamOne.keyString), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (allianceStatus) in
            allianceStatus.numberNumber = NSNumber(value: model.number)
            allianceStatus.pickNumber = NSNumber(value: model.pick)
            allianceStatus.name = model.name

            allianceStatus.updateToOneRelationship(relationship: #keyPath(EventStatusAlliance.backup), newValue: model.backup, newObject: {
                return EventAllianceBackup.insert($0, in: context)
            })
        })
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        if let backup = backup {
            if backup.alliances.count == 0 && backup.allianceStatus == self {
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
        return eventStatusOne == nil
    }

}
