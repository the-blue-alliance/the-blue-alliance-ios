import CoreData
import Foundation
import TBAKit

@objc(DistrictEventPoints)
public class DistrictEventPoints: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DistrictEventPoints> {
        return NSFetchRequest<DistrictEventPoints>(entityName: "DistrictEventPoints")
    }

    @NSManaged public fileprivate(set) var alliancePoints: Int16
    @NSManaged public fileprivate(set) var awardPoints: Int16
    @NSManaged public fileprivate(set) var districtCMP: NSNumber?
    @NSManaged public fileprivate(set) var elimPoints: Int16
    @NSManaged public fileprivate(set) var qualPoints: Int16
    @NSManaged public fileprivate(set) var total: Int16
    @NSManaged public fileprivate(set) var districtRanking: DistrictRanking?
    @NSManaged public fileprivate(set) var event: Event
    @NSManaged public fileprivate(set) var team: Team

}

extension DistrictEventPoints {

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
                                       #keyPath(DistrictEventPoints.event.key), eventKey)
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
                                    #keyPath(DistrictEventPoints.event.key), model.eventKey,
                                    #keyPath(DistrictEventPoints.team.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate) { (eventPoints) in
            eventPoints.team = Team.insert(model.teamKey, in: context)
            eventPoints.event = Event.insert(model.eventKey, in: context)

            eventPoints.alliancePoints = Int16(model.alliancePoints)
            eventPoints.awardPoints = Int16(model.awardPoints)
            if let districtCMP = model.districtCMP {
                eventPoints.districtCMP = NSNumber(value: districtCMP)
            } else {
                eventPoints.districtCMP = nil
            }
            eventPoints.elimPoints = Int16(model.elimPoints)
            eventPoints.qualPoints = Int16(model.qualPoints)
            eventPoints.total = Int16(model.total)
        }
    }

}

extension DistrictEventPoints: Managed {

    public var isOrphaned: Bool {
        // If the Event doesn't exist and it's not attached to a District Ranking, it's an orphan
        // TODO: Can `event` ever be nil here?
        return districtRanking == nil && event == nil
    }

}
