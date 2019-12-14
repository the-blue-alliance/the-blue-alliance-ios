import CoreData
import Foundation
import TBAKit

@objc(EventTeamStat)
public class EventTeamStat: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventTeamStat> {
        return NSFetchRequest<EventTeamStat>(entityName: EventTeamStat.entityName)
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

    @NSManaged var ccwmNumber: NSNumber?
    @NSManaged var dprNumber: NSNumber?
    @NSManaged var oprNumber: NSNumber?
    @NSManaged var eventOne: Event?
    @NSManaged var teamOne: Team?

}

extension EventTeamStat: Managed {

    public static func insert(_ model: TBAStat, eventKey: String, in context: NSManagedObjectContext) -> EventTeamStat {
        let predicate = EventTeamStat.predicate(eventKey: eventKey, teamKey: model.teamKey)
        return findOrCreate(in: context, matching: predicate) { (stat) in
            stat.teamOne = Team.insert(model.teamKey, in: context)

            stat.oprNumber = NSNumber(value: model.opr)
            stat.dprNumber = NSNumber(value: model.dpr)
            stat.ccwmNumber = NSNumber(value: model.ccwm)
        }
    }

}

extension EventTeamStat {

    public static func predicate(eventKey: String, teamKey: String) -> NSPredicate {
        let eventPredicate = EventTeamStat.eventPredicate(eventKey: eventKey)
        let teamPredicate = NSPredicate(format: "%K == %@",
                                        #keyPath(EventTeamStat.teamOne.keyString), teamKey)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [eventPredicate, teamPredicate])
    }

    public static func eventPredicate(eventKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(EventTeamStat.eventOne.keyRaw), eventKey)
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
