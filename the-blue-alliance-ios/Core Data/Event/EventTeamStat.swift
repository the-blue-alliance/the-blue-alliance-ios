import Foundation
import CoreData

extension EventTeamStat: Managed {

    static func insert(_ model: TBAStat, eventKey: String, in context: NSManagedObjectContext) -> EventTeamStat {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventTeamStat.teamKey.key), model.teamKey,
                                    #keyPath(EventTeamStat.event.key), eventKey)

        return findOrCreate(in: context, matching: predicate) { (stat) in
            stat.teamKey = TeamKey.insert(withKey: model.teamKey, in: context)

            stat.opr = model.opr as NSNumber
            stat.dpr = model.dpr as NSNumber
            stat.ccwm = model.ccwm as NSNumber
        }
    }

    var isOrphaned: Bool {
        // Should not be orphaned, since we cascade on Event deletion
        return event == nil
    }

}
