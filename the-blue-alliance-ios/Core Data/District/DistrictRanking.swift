import Foundation
import TBAKit
import CoreData

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
    private static func insert(_ model: TBADistrictRanking, districtKey: String, in context: NSManagedObjectContext) -> DistrictRanking {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(DistrictRanking.district.key), districtKey,
                                    #keyPath(DistrictRanking.teamKey.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.teamKey = TeamKey.insert(withKey: model.teamKey, in: context)

            ranking.pointTotal = model.pointTotal as NSNumber
            ranking.rank = model.rank as NSNumber
            ranking.rookieBonus = model.rookieBonus as NSNumber?

            let eventPoints = model.eventPoints.compactMap({ (modelPoints) -> DistrictEventPoints? in
                let eventPredicate = NSPredicate(format: "%K == %@",
                                                 #keyPath(Event.key), modelPoints.eventKey)

                guard let event = Event.findOrFetch(in: context, matching: eventPredicate) else {
                    return nil
                }
                return DistrictEventPoints.insert(modelPoints, event: event, in: context)
            })
            updateToManyRelationship(relationship: &ranking.eventPoints, newValues: eventPoints, matchingOrphans: { (localRanking) in
                return localRanking.districtRanking == ranking
            }, in: context)
        })
    }

    /**
     Insert an array of District Rankings with values from TBAKit District Ranking models in to the managed object context.

     This method manages setting up a District Ranking's relationship to a District and deleting orphaned District Rankings.

     - Parameter rankings: The TBAKit District Ranking representations to set values from.

     - Parameter district: The District the District Rankings belong to.

     - Parameter context: The NSManagedContext to insert the District Ranking in to.

     - Returns: An array of inserted District Rankings.
     */
    @discardableResult
    static func insert(_ rankings: [TBADistrictRanking], district: District, in context: NSManagedObjectContext) -> [DistrictRanking] {
        let rankings = rankings.map({
            return DistrictRanking.insert($0, districtKey: district.key!, in: context)
        })
        updateToManyRelationship(relationship: &district.rankings, newValues: rankings, matchingOrphans: { _ in
            // Rankings will never belong to more than one district, so this should always be true
            return true
        }, in: context)
        return rankings
    }

}
