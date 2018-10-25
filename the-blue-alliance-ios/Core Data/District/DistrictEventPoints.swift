import Foundation
import CoreData
import TBAKit

extension DistrictEventPoints: Managed {

    /**
     Insert a District Event Points with values from a TBAKit District Event Points model in to the managed object context.

     - Important: This method does not manage setting up a District Event Points' relationship to an Event or District Ranking.

     - Parameter model: The TBAKit District Event Points representation to set values from.

     - Parameter context: The NSManagedContext to insert the District Event Points in to.

     - Returns: The inserted District Event Points.
     */
    private static func insert(_ model: TBADistrictEventPoints, in context: NSManagedObjectContext) -> DistrictEventPoints {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(DistrictEventPoints.event.key), model.eventKey,
                                    #keyPath(DistrictEventPoints.teamKey.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate) { (eventPoints) in
            eventPoints.teamKey = TeamKey.insert(withKey: model.teamKey, in: context)

            eventPoints.alliancePoints = model.alliancePoints as NSNumber
            eventPoints.awardPoints = model.awardPoints as NSNumber
            eventPoints.districtCMP = model.districtCMP as NSNumber?
            eventPoints.elimPoints = model.elimPoints as NSNumber
            eventPoints.qualPoints = model.qualPoints as NSNumber
            eventPoints.total = model.total as NSNumber
        }
    }

    /**
     Insert a District Event Points with values from a TBAKit District Event Points model in to the managed object context.

     This method manages setting up a District Event Points' relationship to an Event. This method should be used when inserting District Event Points for an Event on District Rankings.

     - Parameter model: The TBAKit District Event Points representation to set values from.

     - Parameter context: The NSManagedContext to insert the Award in to.

     - Returns: The inserted District Event Points.
     */
    @discardableResult
    static func insert(_ model: TBADistrictEventPoints, event: Event, in context: NSManagedObjectContext) -> DistrictEventPoints {
        let points = DistrictEventPoints.insert(model, in: context)
        event.addToPoints(points)
        return points
    }

    // TODO: Insert for Event... (~this needs tests~)
    /**
     Insert an array of District Event Points with values from TBAKit District Event Points models in to the managed object context.

     This method manages setting up a District Event Points' relationship to an Event and deleting orphaned District Event Points.

     - Parameter points: The TBAKit District Event Points representations to set values from.

     - Parameter event: The Event the District Event Points belong to.

     - Parameter context: The NSManagedContext to insert the District Event Points in to.

     - Returns: An array of inserted District Event Points.
     */
    @discardableResult
    static func insert(_ points: [TBADistrictEventPoints], event: Event, in context: NSManagedObjectContext) -> [DistrictEventPoints] {
        let points = points.map({
            return DistrictEventPoints.insert($0, in: context)
        })
        updateToManyRelationship(relationship: &event.points, newValues: points, matchingOrphans: { _ in
            // Rankings will never belong to more than one district, so this should always be true
            return true
        }, in: context)
        return points
    }

}
