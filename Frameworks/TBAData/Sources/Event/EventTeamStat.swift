import CoreData
import Foundation
import TBAKit

@objc(EventTeamStat)
public class EventTeamStat: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventTeamStat> {
        return NSFetchRequest<EventTeamStat>(entityName: "EventTeamStat")
    }

    @NSManaged private var ccwmNumber: NSNumber?
    @NSManaged private var dprNumber: NSNumber?
    @NSManaged private var oprNumber: NSNumber?
    @NSManaged private var eventOne: Event?
    @NSManaged private var teamOne: Team?

}

extension EventTeamStat: Managed {

    public static func insert(_ model: TBAStat, eventKey: String, in context: NSManagedObjectContext) -> EventTeamStat {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(EventTeamStat.teamOne.keyString), model.teamKey,
                                    #keyPath(EventTeamStat.eventOne.keyString), eventKey)

        return findOrCreate(in: context, matching: predicate) { (stat) in
            stat.teamOne = Team.insert(model.teamKey, in: context)

            stat.oprNumber = NSNumber(value: model.opr)
            stat.dprNumber = NSNumber(value: model.dpr)
            stat.ccwmNumber = NSNumber(value: model.ccwm)
        }
    }

}

extension EventTeamStat: Orphanable {

    public var isOrphaned: Bool {
        // Should not be orphaned, since we cascade on Event deletion
        return eventOne == nil
    }

}
