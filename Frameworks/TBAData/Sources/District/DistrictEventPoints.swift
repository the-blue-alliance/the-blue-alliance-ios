import CoreData
import Foundation
import TBAKit

extension DistrictEventPoints {

    public var alliancePoints: Int {
        guard let alliancePoints = getValue(\DistrictEventPoints.alliancePointsRaw)?.intValue else {
            fatalError("Save DistrictEventPoints before accessing alliancePoints")
        }
        return alliancePoints
    }

    public var awardPoints: Int {
        guard let awardPoints = getValue(\DistrictEventPoints.awardPointsRaw)?.intValue else {
            fatalError("Save DistrictEventPoints before accessing awardPoints")
        }
        return awardPoints
    }

    public var districtCMP: Bool? {
        return getValue(\DistrictEventPoints.districtCMPRaw)?.boolValue
    }

    public var elimPoints: Int {
        guard let elimPoints = getValue(\DistrictEventPoints.elimPointsRaw)?.intValue else {
            fatalError("Save DistrictEventPoints before accessing elimPoints")
        }
        return elimPoints
    }

    public var qualPoints: Int {
        guard let qualPoints = getValue(\DistrictEventPoints.qualPointsRaw)?.intValue else {
            fatalError("Save DistrictEventPoints before accessing qualPoints")
        }
        return qualPoints
    }

    public var total: Int {
        guard let total = getValue(\DistrictEventPoints.totalRaw)?.intValue else {
            fatalError("Save DistrictEventPoints before accessing total")
        }
        return total
    }

    public var districtRanking: DistrictRanking? {
        return getValue(\DistrictEventPoints.districtRankingRaw)
    }

    public var event: Event {
        guard let event = getValue(\DistrictEventPoints.eventRaw) else {
            fatalError("Save DistrictEventPoints before accessing event")
        }
        return event
    }

    public var team: Team {
        guard let team = getValue(\DistrictEventPoints.teamRaw) else {
            fatalError("Save DistrictEventPoints before accessing team")
        }
        return team
    }

}

@objc(DistrictEventPoints)
public class DistrictEventPoints: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DistrictEventPoints> {
        return NSFetchRequest<DistrictEventPoints>(entityName: DistrictEventPoints.entityName)
    }

    @NSManaged var alliancePointsRaw: NSNumber?
    @NSManaged var awardPointsRaw: NSNumber?
    @NSManaged var districtCMPRaw: NSNumber?
    @NSManaged var elimPointsRaw: NSNumber?
    @NSManaged var qualPointsRaw: NSNumber?
    @NSManaged var totalRaw: NSNumber?
    @NSManaged var districtRankingRaw: DistrictRanking?
    @NSManaged var eventRaw: Event?
    @NSManaged var teamRaw: Team?

}

extension DistrictEventPoints {

    public static func eventPredicate(eventKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(DistrictEventPoints.eventRaw.keyRaw), eventKey)
    }

    public static func totalSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(DistrictEventPoints.totalRaw), ascending: false)
    }

}

extension DistrictEventPoints: Managed {

    /**
     Insert an array of District Event Points for an Event with values from TBAKit District Event Points models in to the managed object context.

     This method manages deleting orphaned District Event Points for the Event.

     This method works slightly differently from other insert array methods, since there's no relationship between an Event <-> DistrictEventPoints - we map to an EventKey, since we may not have an Event when inserting DistrictEventPoints in the case of DistrictEventPoints coming from DistrictRanking models.

     - Parameter points: The TBAKit District Event Points representations to set values from.

     - Parameter eventKey: The key for the Event the District Event Points belong to.

     - Parameter context: The NSManagedContext to insert the District Event Points in to.

     - Returns: An array of inserted District Event Points.
     */
    public static func insert(_ points: [TBADistrictEventPoints], eventKey: String, in context: NSManagedObjectContext) {
        // Fetch all of the previous DistrictEventPoints for this Event
        let oldPoints = DistrictEventPoints.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K == %@",
                                       #keyPath(DistrictEventPoints.eventRaw.keyRaw), eventKey)
        }

        // Insert new DistrictEventPoints for this Event
        let points = points.map({
            return DistrictEventPoints.insert($0, in: context)
        })

        // Delete orphaned DistrictEventPoints for this Event
        Set(oldPoints).subtracting(Set(points)).forEach({
            context.delete($0)
        })
    }

    /**
     Insert a District Event Points with values from a TBAKit District Event Points model in to the managed object context.

     - Important: Method does not setup a relationship between a DistrictEventPoints and a DistrictRanking.

     - Parameter model: The TBAKit District Event Points representation to set values from.

     - Parameter context: The NSManagedContext to insert the District Event Points in to.

     - Returns: The inserted District Event Points.
     */
    public static func insert(_ model: TBADistrictEventPoints, in context: NSManagedObjectContext) -> DistrictEventPoints {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(DistrictEventPoints.eventRaw.keyRaw), model.eventKey,
                                    #keyPath(DistrictEventPoints.teamRaw.keyRaw), model.teamKey)
        return findOrCreate(in: context, matching: predicate) { (eventPoints) in
            eventPoints.teamRaw = Team.insert(model.teamKey, in: context)
            eventPoints.eventRaw = Event.insert(model.eventKey, in: context)

            eventPoints.alliancePointsRaw = NSNumber(value: model.alliancePoints)
            eventPoints.awardPointsRaw = NSNumber(value: model.awardPoints)
            if let districtCMP = model.districtCMP {
                eventPoints.districtCMPRaw = NSNumber(value: districtCMP)
            } else {
                eventPoints.districtCMPRaw = nil
            }
            eventPoints.elimPointsRaw = NSNumber(value: model.elimPoints)
            eventPoints.qualPointsRaw = NSNumber(value: model.qualPoints)
            eventPoints.totalRaw = NSNumber(value: model.total)
        }
    }

}

extension DistrictEventPoints: Orphanable {

    public var isOrphaned: Bool {
        // If the Event doesn't exist and it's not attached to a District Ranking, it's an orphan
        return districtRankingRaw == nil && eventRaw == nil
    }

}
