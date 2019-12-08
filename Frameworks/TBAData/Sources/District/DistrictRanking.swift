import CoreData
import Foundation
import TBAKit

extension DistrictRanking {

    public var sortedEventPoints: [DistrictEventPoints] {
        // TODO: This sort is going to be problematic if we don't have Event objects
        let eventPointsSet = getValue(\DistrictRanking.eventPoints)
        return (eventPointsSet?.allObjects as? [DistrictEventPoints])?.sorted(by: { (lhs, rhs) -> Bool in
            guard let lhsEvent = lhs.getValue(\DistrictEventPoints.event) else {
                return false
            }
            guard let lhsStartDate = lhsEvent.getValue(\Event.startDate) else {
                return false
            }
            guard let rhsEvent = rhs.getValue(\DistrictEventPoints.event) else {
                return false
            }
            guard let rhsStartDate = rhsEvent.getValue(\Event.startDate) else {
                return false
            }
            return rhsStartDate > lhsStartDate
        }) ?? []
    }

}

extension DistrictRanking: Managed {

    /**
     Insert a District Ranking with values from a TBAKit District Ranking model in to the managed object context.

     This method manages deleting orphaned District Event Points.

     - Important: This method does not manage setting up a District Ranking's relationship to a District.

     - Parameter model: The TBAKit District Ranking representation to set values from.

     - Parameter districtKey: The District key the District Ranking belongs to.

     - Parameter context: The NSManagedContext to insert the District Ranking in to.

     - Returns: The inserted District Ranking.
     */
    public static func insert(_ model: TBADistrictRanking, districtKey: String, in context: NSManagedObjectContext) -> DistrictRanking {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(DistrictRanking.district.key), districtKey,
                                    #keyPath(DistrictRanking.team.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.team = Team.insert(model.teamKey, in: context)

            ranking.pointTotal = model.pointTotal as NSNumber
            ranking.rank = model.rank as NSNumber
            ranking.rookieBonus = model.rookieBonus as NSNumber?

            ranking.updateToManyRelationship(relationship: #keyPath(DistrictRanking.eventPoints), newValues: model.eventPoints.compactMap({
                return DistrictEventPoints.insert($0, in: context)
            }))
        })
    }

    public var isOrphaned: Bool {
        return district == nil
    }

}
