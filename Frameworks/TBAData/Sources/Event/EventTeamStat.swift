import CoreData
import Foundation
import TBAKit

extension EventTeamStat {

    public var opr: Double {
        guard let opr = getValue(\EventTeamStat.oprRaw)?.doubleValue else {
            fatalError("Save EventTeamStat before accessing opr")
        }
        return opr
    }

    public var dpr: Double {
        guard let dpr = getValue(\EventTeamStat.dprRaw)?.doubleValue else {
            fatalError("Save EventTeamStat before accessing dpr")
        }
        return dpr
    }

    public var ccwm: Double {
        guard let ccwm = getValue(\EventTeamStat.ccwmRaw)?.doubleValue else {
            fatalError("Save EventTeamStat before accessing ccwm")
        }
        return ccwm
    }

    public var event: Event {
        guard let event = getValue(\EventTeamStat.eventRaw) else {
            fatalError("Save EventTeamStat before accessing event")
        }
        return event
    }

    public var team: Team {
        guard let team = getValue(\EventTeamStat.teamRaw) else {
            fatalError("Save EventTeamStat before accessing team")
        }
        return team
    }

}

@objc(EventTeamStat)
public class EventTeamStat: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventTeamStat> {
        return NSFetchRequest<EventTeamStat>(entityName: EventTeamStat.entityName)
    }

    @NSManaged var ccwmRaw: NSNumber?
    @NSManaged var dprRaw: NSNumber?
    @NSManaged var oprRaw: NSNumber?
    @NSManaged var eventRaw: Event?
    @NSManaged var teamRaw: Team?

}

extension EventTeamStat: Managed {

    public static func insert(_ model: TBAStat, eventKey: String, in context: NSManagedObjectContext) -> EventTeamStat {
        let predicate = NSPredicate(format: "%K == %@ && %K == %@",
                                    #keyPath(EventTeamStat.eventRaw.keyRaw), eventKey,
                                    #keyPath(EventTeamStat.teamRaw.keyRaw), model.teamKey)
        return findOrCreate(in: context, matching: predicate) { (stat) in
            stat.teamRaw = Team.insert(model.teamKey, in: context)

            stat.oprRaw = NSNumber(value: model.opr)
            stat.dprRaw = NSNumber(value: model.dpr)
            stat.ccwmRaw = NSNumber(value: model.ccwm)
        }
    }

}

extension EventTeamStat {

    public static func oprSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(EventTeamStat.oprRaw), ascending: false)
    }

    public static func dprSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(EventTeamStat.dprRaw), ascending: false)
    }

    public static func ccwmSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(EventTeamStat.ccwmRaw), ascending: false)
    }

}

extension EventTeamStat: Orphanable {

    public var isOrphaned: Bool {
        // Should not be orphaned, since we cascade on Event deletion
        return eventRaw == nil
    }

}
