import CoreData
import Foundation
import TBAKit

@objc(EventStatus)
public class EventStatus: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatus> {
        return NSFetchRequest<EventStatus>(entityName: EventStatus.entityName)
    }

    @NSManaged public private(set) var allianceStatus: String?
    @NSManaged public private(set) var lastMatchKey: String?
    @NSManaged public private(set) var nextMatchKey: String?
    @NSManaged public private(set) var overallStatus: String?
    @NSManaged public private(set) var playoffStatus: String?

    @NSManaged private var alliance: EventStatusAlliance?
    @NSManaged private var eventOne: Event?
    @NSManaged private var playoff: EventStatusPlayoff?
    @NSManaged internal private(set) var qual: EventStatusQual?
    @NSManaged private var teamOne: Team?

}

extension EventStatus: Managed {

    @discardableResult
    public static func insert(_ model: TBAEventStatus, in context: NSManagedObjectContext) -> EventStatus {
        let predicate = EventStatus.predicate(eventKey: model.eventKey, teamKey: model.teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (eventStatus) in
            eventStatus.teamOne = Team.insert(model.teamKey, in: context)

            eventStatus.allianceStatus = model.allianceStatusString
            eventStatus.playoffStatus = model.playoffStatusString
            eventStatus.overallStatus = model.overallStatusString

            eventStatus.nextMatchKey = model.nextMatchKey
            eventStatus.lastMatchKey = model.lastMatchKey

            eventStatus.updateToOneRelationship(relationship: #keyPath(EventStatus.qual), newValue: model.qual) {
                return EventStatusQual.insert($0, eventKey: model.eventKey, teamKey: model.teamKey, in: context)
            }
            eventStatus.updateToOneRelationship(relationship: #keyPath(EventStatus.alliance), newValue: model.alliance) {
                return EventStatusAlliance.insert($0, eventKey: model.eventKey, teamKey: model.teamKey, in: context)
            }
            eventStatus.updateToOneRelationship(relationship: #keyPath(EventStatus.playoff), newValue: model.playoff) {
                return EventStatusPlayoff.insert($0, eventKey: model.eventKey, teamKey: model.teamKey, in: context)
            }
        })
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        if let qual = qual {
            if qual.ranking == nil {
                // EventStatusQual will become an orphan - delete
                managedObjectContext?.delete(qual)
            } else {
                qual.eventStatus = nil
            }
        }

        if let playoff = playoff {
            if playoff.alliance == nil {
                // EventStatusPlayoff will become an orphan - delete
                managedObjectContext?.delete(playoff)
            } else {
                playoff.eventStatus = nil
            }
        }
    }

}

extension EventStatus {

    public static func eventKeyPath() -> String {
        return #keyPath(EventStatus.eventOne)
    }

    public static func teamKeyPath() -> String {
        return #keyPath(EventStatus.teamOne)
    }

    public static func predicate(eventKey: String, teamKey: String) -> NSPredicate {
        return NSPredicate(format: "%K.%K == %@ AND %K.%K == %@",
                           EventStatus.eventKeyPath(), Event.keyPath(), eventKey,
                           EventStatus.teamKeyPath(), #keyPath(Team.keyString), teamKey)
    }

}
