import CoreData
import Foundation
import TBAKit

@objc(EventTeamStat)
public class EventTeamStat: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventTeamStat> {
        return NSFetchRequest<EventTeamStat>(entityName: "EventTeamStat")
    }

    @NSManaged public fileprivate(set) var ccwm: Double
    @NSManaged public fileprivate(set) var dpr: Double
    @NSManaged public fileprivate(set) var opr: Double
    @NSManaged public fileprivate(set) var event: Event
    @NSManaged public fileprivate(set) var team: Team

}

extension EventTeamStat {

    public static func insert(_ model: TBAStat, eventKey: String, in context: NSManagedObjectContext) -> EventTeamStat {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventTeamStat.team.key), model.teamKey,
                                    #keyPath(EventTeamStat.event.key), eventKey)

        return findOrCreate(in: context, matching: predicate) { (stat) in
            stat.team = Team.insert(model.teamKey, in: context)

            stat.opr = model.opr
            stat.dpr = model.dpr
            stat.ccwm = model.ccwm
        }
    }

}

extension EventTeamStat: Managed {

    public var isOrphaned: Bool {
        // Should not be orphaned, since we cascade on Event deletion
        // TODO: Can this ever be nil?
        return event == nil
    }

}
