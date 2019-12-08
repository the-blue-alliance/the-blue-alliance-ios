import CoreData
import Foundation
import TBAKit

extension EventTeamStat: Managed {

    public static func insert(_ model: TBAStat, eventKey: String, in context: NSManagedObjectContext) -> EventTeamStat {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventTeamStat.team.key), model.teamKey,
                                    #keyPath(EventTeamStat.event.key), eventKey)

        return findOrCreate(in: context, matching: predicate) { (stat) in
            stat.team = Team.insert(model.teamKey, in: context)

            stat.opr = model.opr as NSNumber
            stat.dpr = model.dpr as NSNumber
            stat.ccwm = model.ccwm as NSNumber
        }
    }

    public var isOrphaned: Bool {
        // Should not be orphaned, since we cascade on Event deletion
        return event == nil
    }

}
