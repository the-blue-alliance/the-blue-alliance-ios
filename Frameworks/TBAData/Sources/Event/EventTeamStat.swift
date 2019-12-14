import CoreData
import Foundation
import TBAKit

@objc(EventTeamStat)
public class EventTeamStat: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventTeamStat> {
        return NSFetchRequest<EventTeamStat>(entityName: "EventTeamStat")
    }

    public var opr: Double {
        guard let opr = oprNumber?.doubleValue else {
            fatalError("Save EventTeamStat before accessing opr")
        }
        return opr
    }

    public var dpr: Double {
        guard let dpr = dprNumber?.doubleValue else {
            fatalError("Save EventTeamStat before accessing dpr")
        }
        return dpr
    }

    public var ccwm: Double {
        guard let ccwm = ccwmNumber?.doubleValue else {
            fatalError("Save EventTeamStat before accessing ccwm")
        }
        return ccwm
    }

    public var event: Event {
        guard let event = eventOne else {
            fatalError("Save EventTeamStat before accessing event")
        }
        return event
    }

    public var team: Team {
        guard let team = teamOne else {
            fatalError("Save EventTeamStat before accessing team")
        }
        return team
    }

    @NSManaged private var ccwmNumber: NSNumber?
    @NSManaged private var dprNumber: NSNumber?
    @NSManaged private var oprNumber: NSNumber?
    @NSManaged private var eventOne: Event?
    @NSManaged private var teamOne: Team?

}

extension EventTeamStat: Managed {

    public static func insert(_ model: TBAStat, eventKey: String, in context: NSManagedObjectContext) -> EventTeamStat {
        let predicate = NSPredicate(format: "%K == %@ AND %K.%K == %@",
                                    #keyPath(EventTeamStat.teamOne.keyString), model.teamKey,
                                    #keyPath(EventTeamStat.eventOne), Event.keyPath(), eventKey)

        return findOrCreate(in: context, matching: predicate) { (stat) in
            stat.teamOne = Team.insert(model.teamKey, in: context)

            stat.oprNumber = NSNumber(value: model.opr)
            stat.dprNumber = NSNumber(value: model.dpr)
            stat.ccwmNumber = NSNumber(value: model.ccwm)
        }
    }

}

extension EventTeamStat {

    public static func predicate(event: Event, team: Team) -> NSPredicate {
        return NSPredicate(format: "%K == %@ AND %K == %@",
                           #keyPath(EventTeamStat.eventOne), event,
                           #keyPath(EventTeamStat.teamOne), team)
    }

    public static func eventPredicate(event: Event) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(EventTeamStat.eventOne), event)
    }

    public static func oprSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(EventTeamStat.oprNumber), ascending: false)
    }

    public static func dprSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(EventTeamStat.dprNumber), ascending: false)
    }

    public static func ccwmSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(EventTeamStat.ccwmNumber), ascending: false)
    }

}

extension EventTeamStat: Orphanable {

    public var isOrphaned: Bool {
        // Should not be orphaned, since we cascade on Event deletion
        return eventOne == nil
    }

}
