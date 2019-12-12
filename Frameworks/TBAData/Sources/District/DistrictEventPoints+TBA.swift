import CoreData
import Foundation
import TBAKit

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

}

extension DistrictEventPoints: Managed {

    public var isOrphaned: Bool {
        // If the Event doesn't exist and it's not attached to a District Ranking, it's an orphan
        // TODO: Can `event` ever be nil here?
        return districtRanking == nil && event == nil
    }

}
