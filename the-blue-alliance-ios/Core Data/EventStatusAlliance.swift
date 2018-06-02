import Foundation
import CoreData
import TBAKit

extension EventStatusAlliance: Managed {
    
    static func insert(with model: TBAEventStatusAlliance, eventStatus: EventStatus, in context: NSManagedObjectContext) -> EventStatusAlliance {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(EventStatusAlliance.eventStatus), eventStatus)
        return findOrCreate(in: context, matching: predicate, configure: { (allianceStatus) in
            allianceStatus.eventStatus = eventStatus
            
            allianceStatus.number = Int16(model.number)
            allianceStatus.pick = Int16(model.pick)
            allianceStatus.name = model.name
            
            if let backup = model.backup {
                allianceStatus.backup = EventAllianceBackup.insert(with: backup, for: allianceStatus, in: context)
            }
        })
    }
    
}
