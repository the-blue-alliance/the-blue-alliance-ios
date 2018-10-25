import Foundation
import CoreData
import TBAKit

extension DistrictEventPoints: Managed {

    /**
     Insert a District Event Points with values from a TBAKit District Event Points model in to the managed object context.

     - Parameter model: The TBAKit District Event Points representation to set values from.

     - Parameter context: The NSManagedContext to insert the District Event Points in to.

     - Returns: The inserted District Event Points.
     */
    static func insert(_ model: TBADistrictEventPoints, in context: NSManagedObjectContext) -> DistrictEventPoints {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(DistrictEventPoints.eventKey.key), model.eventKey,
                                    #keyPath(DistrictEventPoints.teamKey.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate) { (eventPoints) in
            eventPoints.teamKey = TeamKey.insert(withKey: model.teamKey, in: context)
            eventPoints.eventKey = EventKey.insert(withKey: model.eventKey, in: context)

            eventPoints.alliancePoints = model.alliancePoints as NSNumber
            eventPoints.awardPoints = model.awardPoints as NSNumber
            eventPoints.districtCMP = model.districtCMP as NSNumber?
            eventPoints.elimPoints = model.elimPoints as NSNumber
            eventPoints.qualPoints = model.qualPoints as NSNumber
            eventPoints.total = model.total as NSNumber
        }
    }

    // TODO: Insert for Event... (~this needs tests~)
    /**
     Insert an array of District Event Points for an Event with values from TBAKit District Event Points models in to the managed object context.

     This method manages deleting orphaned District Event Points for the Event.

     - Parameter points: The TBAKit District Event Points representations to set values from.

     - Parameter eventKey: The key for the Event the District Event Points belong to.

     - Parameter context: The NSManagedContext to insert the District Event Points in to.

     - Returns: An array of inserted District Event Points.
     */
    @discardableResult
    static func insert(_ points: [TBADistrictEventPoints], eventKey: String, in context: NSManagedObjectContext) -> [DistrictEventPoints] {
        // Fetch all of the previous DistrictEventPoints for this Event
        let oldPoints = DistrictEventPoints.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K == %@",
                                       #keyPath(DistrictEventPoints.eventKey.key), eventKey)
        }

        // Insert new DistrictEventPoints for this Event
        let points = points.map({
            return DistrictEventPoints.insert($0, in: context)
        })

        // Delete orphaned DistrictEventPoints for this Event
        Set(oldPoints).subtracting(Set(points)).forEach({
            // If they were previously attached to a District, the next refresh of the District Event Points should
            // report that these points don't exist anymore
            context.delete($0)
        })

        return points
    }

}
