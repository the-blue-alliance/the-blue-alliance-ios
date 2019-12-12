import Foundation
import CoreData
import TBAKit

@objc(DistrictRanking)
public class DistrictRanking: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DistrictRanking> {
        return NSFetchRequest<DistrictRanking>(entityName: "DistrictRanking")
    }

    @NSManaged public fileprivate(set) var pointTotal: Int16
    @NSManaged public fileprivate(set) var rank: Int16
    @NSManaged public fileprivate(set) var rookieBonus: NSNumber?
    @NSManaged public fileprivate(set) var district: District
    @NSManaged public fileprivate(set) var eventPoints: NSSet
    @NSManaged public fileprivate(set) var team: Team

}

extension DistrictRanking {

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

            ranking.pointTotal = Int16(model.pointTotal)
            ranking.rank = Int16(model.rank)
            ranking.rookieBonus = model.rookieBonus as NSNumber?

            ranking.updateToManyRelationship(relationship: #keyPath(DistrictRanking.eventPoints), newValues: model.eventPoints.compactMap {
                return DistrictEventPoints.insert($0, in: context)
            })
        })
    }

}

extension DistrictRanking {

    // TODO: Audit the uses of this to see if we can have empty events when using this
    public var sortedEventPoints: [DistrictEventPoints] {
        let eventPointsSet = getValue(\DistrictRanking.eventPoints)
        return (eventPointsSet.allObjects as? [DistrictEventPoints])?.sorted(by: { (lhs, rhs) -> Bool in
            let lhsEvent = lhs.getValue(\DistrictEventPoints.event)
            guard let lhsStartDate = lhsEvent.getValue(\Event.startDate) else {
                return false
            }
            let rhsEvent = rhs.getValue(\DistrictEventPoints.event)
            guard let rhsStartDate = rhsEvent.getValue(\Event.startDate) else {
                return false
            }
            return rhsStartDate > lhsStartDate
        }) ?? []
    }

}

extension DistrictRanking: Managed {

    public var isOrphaned: Bool {
        return district == nil
    }

}
