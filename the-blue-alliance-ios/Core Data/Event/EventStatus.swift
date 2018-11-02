import Foundation
import CoreData
import TBAKit

extension EventStatus: Managed {

    @discardableResult
    static func insert(_ model: TBAEventStatus, in context: NSManagedObjectContext) -> EventStatus {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventStatus.event.key), model.eventKey,
                                    #keyPath(EventStatus.teamKey.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (eventStatus) in
            eventStatus.teamKey = TeamKey.insert(withKey: model.teamKey, in: context)

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

    var isOrphaned: Bool {
        return event == nil
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
