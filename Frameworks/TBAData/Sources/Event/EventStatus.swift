import CoreData
import Foundation
import TBAKit

@objc(EventStatus)
public class EventStatus: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatus> {
        return NSFetchRequest<EventStatus>(entityName: "EventStatus")
    }

    @NSManaged public fileprivate(set) var allianceStatus: String?
    @NSManaged public fileprivate(set) var lastMatchKey: String?
    @NSManaged public fileprivate(set) var nextMatchKey: String?
    @NSManaged public fileprivate(set) var overallStatus: String?
    @NSManaged public fileprivate(set) var playoffStatus: String?
    @NSManaged public fileprivate(set) var alliance: EventStatusAlliance?
    @NSManaged public fileprivate(set) var event: Event
    @NSManaged public fileprivate(set) var playoff: EventStatusPlayoff?
    @NSManaged public fileprivate(set) var qual: EventStatusQual?
    @NSManaged public fileprivate(set) var team: Team

}

extension EventStatus: Managed {

    @discardableResult
    public static func insert(_ model: TBAEventStatus, in context: NSManagedObjectContext) -> EventStatus {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventStatus.event.key), model.eventKey,
                                    #keyPath(EventStatus.team.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (eventStatus) in
            eventStatus.team = Team.insert(model.teamKey, in: context)

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

// TODO: Orphable?
