import Foundation
import TBAKit
import CoreData

extension EventTeamStat: Managed {

    @discardableResult
    static func insert(with model: TBAStat, for event: Event, in context: NSManagedObjectContext) -> EventTeamStat {
        let team = Team.insert(withKey: model.teamKey, in: context)
        return insert(with: model, for: event, and: team, in: context)
    }

    static func insert(with model: TBAStat, for event: Event, and team: Team, in context: NSManagedObjectContext) -> EventTeamStat {
        let predicate = NSPredicate(format: "team == %@ AND event == %@", team, event)
        return findOrCreate(in: context, matching: predicate) { (stat) in
            stat.team = team
            stat.event = event

            stat.opr = model.opr
            stat.dpr = model.dpr
            stat.ccwm = model.ccwm
        }
    }

}
