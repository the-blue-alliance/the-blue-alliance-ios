import Foundation
import TBAKit
import CoreData

extension EventTeamStat: Managed {

    static func insert(with model: TBAStat, for event: Event, in context: NSManagedObjectContext) -> EventTeamStat {
        let teamKey = TeamKey.insert(withKey: model.teamKey, in: context)
        return insert(with: model, for: event, and: teamKey, in: context)
    }

    static func insert(with model: TBAStat, for event: Event, and teamKey: TeamKey, in context: NSManagedObjectContext) -> EventTeamStat {
        let predicate = NSPredicate(format: "teamKey == %@ AND event == %@", teamKey, event)
        return findOrCreate(in: context, matching: predicate) { (stat) in
            stat.teamKey = teamKey
            stat.event = event

            stat.opr = model.opr
            stat.dpr = model.dpr
            stat.ccwm = model.ccwm
        }
    }

}
