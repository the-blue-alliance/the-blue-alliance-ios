import Foundation
import CoreData
import TBAKit

extension EventStatus: Managed {

    @discardableResult
    static func insert(with model: TBAEventStatus, event: Event, in context: NSManagedObjectContext) -> EventStatus {
        let teamKey = TeamKey.insert(withKey: model.teamKey, in: context)
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventStatus.event), event, #keyPath(EventStatus.teamKey), teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (eventStatus) in
            eventStatus.teamKey = teamKey
            eventStatus.event = event

            eventStatus.allianceStatus = model.allianceStatusString
            eventStatus.playoffStatus = model.playoffStatusString
            eventStatus.overallStatus = model.overallStatusString

            eventStatus.nextMatchKey = model.nextMatchKey
            eventStatus.lastMatchKey = model.lastMatchKey

            if let qual = model.qual {
                eventStatus.qual = EventStatusQual.insert(with: qual, eventStatus: eventStatus, in: context)
            }
            if let alliance = model.alliance {
                eventStatus.alliance = EventStatusAlliance.insert(with: alliance, eventStatus: eventStatus, in: context)
            }
            if let playoff = model.playoff {
                eventStatus.playoff = EventAllianceStatus.insert(with: playoff, for: eventStatus, in: context)
            }
        })
    }

}
