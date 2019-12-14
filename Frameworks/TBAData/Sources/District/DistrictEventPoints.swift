import CoreData
import Foundation
import TBAKit

@objc(DistrictEventPoints)
public class DistrictEventPoints: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DistrictEventPoints> {
        return NSFetchRequest<DistrictEventPoints>(entityName: DistrictEventPoints.entityName)
    }

    public var alliancePoints: Int {
        guard let alliancePoints = alliancePointsNumber?.intValue else {
            fatalError("Save DistrictEventPoints before accessing alliancePoints")
        }
        return alliancePoints
    }

    public var awardPoints: Int {
        guard let awardPoints = awardPointsNumber?.intValue else {
            fatalError("Save DistrictEventPoints before accessing awardPoints")
        }
        return awardPoints
    }

    public var districtCMP: Bool? {
        return districtCMPNumber?.boolValue
    }

    public var elimPoints: Int {
        guard let elimPoints = elimPointsNumber?.intValue else {
            fatalError("Save DistrictEventPoints before accessing elimPoints")
        }
        return elimPoints
    }

    public var qualPoints: Int {
        guard let qualPoints = qualPointsNumber?.intValue else {
            fatalError("Save DistrictEventPoints before accessing qualPoints")
        }
        return qualPoints
    }

    public var total: Int {
        guard let total = totalNumber?.intValue else {
            fatalError("Save DistrictEventPoints before accessing total")
        }
        return total
    }

    @NSManaged private var alliancePointsNumber: NSNumber?
    @NSManaged private var awardPointsNumber: NSNumber?
    @NSManaged private var districtCMPNumber: NSNumber?
    @NSManaged private var elimPointsNumber: NSNumber?
    @NSManaged private var qualPointsNumber: NSNumber?
    @NSManaged private var totalNumber: NSNumber?

    public var event: Event {
        guard let event = eventOne else {
            fatalError("Save DistrictEventPoints before accessing event")
        }
        return event
    }

    public var team: Team {
        guard let team = teamOne else {
            fatalError("Save DistrictEventPoints before accessing team")
        }
        return team
    }

    @NSManaged private var districtRanking: DistrictRanking?
    @NSManaged private var eventOne: Event?
    @NSManaged private var teamOne: Team?

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
            $0.predicate = DistrictEventPoints.eventPredicate(eventKey: eventKey)
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
        let predicate = NSPredicate(format: "%K.%K == %@ AND %K == %@",
                                    #keyPath(DistrictEventPoints.eventOne), Event.keyPath(), model.eventKey,
                                    #keyPath(DistrictEventPoints.teamOne.keyString), model.teamKey)

        return findOrCreate(in: context, matching: predicate) { (eventPoints) in
            eventPoints.teamOne = Team.insert(model.teamKey, in: context)
            eventPoints.eventOne = Event.insert(model.eventKey, in: context)

            eventPoints.alliancePointsNumber = NSNumber(value: model.alliancePoints)
            eventPoints.awardPointsNumber = NSNumber(value: model.awardPoints)
            if let districtCMP = model.districtCMP {
                eventPoints.districtCMPNumber = NSNumber(value: districtCMP)
            } else {
                eventPoints.districtCMPNumber = nil
            }
            eventPoints.elimPointsNumber = NSNumber(value: model.elimPoints)
            eventPoints.qualPointsNumber = NSNumber(value: model.qualPoints)
            eventPoints.totalNumber = NSNumber(value: model.total)
        }
    }

}

extension DistrictEventPoints {

    public static func eventPredicate(eventKey: String) -> NSPredicate {
        return NSPredicate(format: "%K.%K == %@",
                           #keyPath(DistrictEventPoints.eventOne), Event.keyPath(), eventKey)
    }

    public static func totalSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(DistrictEventPoints.totalNumber), ascending: false)
    }

}

extension DistrictEventPoints: Orphanable {

    public var isOrphaned: Bool {
        // If the Event doesn't exist and it's not attached to a District Ranking, it's an orphan
        return districtRanking == nil && eventOne == nil
    }

}
