import Foundation
import CoreData
import TBAKit

@objc(DistrictRanking)
public class DistrictRanking: NSManagedObject {

    public var pointTotal: Int {
        guard let pointTotal = pointTotalNumber?.intValue else {
            fatalError("Save DistrictRanking before accessing pointTotal")
        }
        return pointTotal
    }

    public var rank: Int {
        guard let rank = rankNumber?.intValue else {
            fatalError("Save DistrictRanking before accessing rank")
        }
        return rank
    }

    public var rookieBonus: Int? {
        return rookieBonusNumber?.intValue
    }

    public var district: District {
        guard let district = districtOne else {
            fatalError("Save DistrictRanking before accessing district")
        }
        return district
    }

    public var eventPoints: [DistrictEventPoints] {
        guard let eventPointsMany = eventPointsMany, let eventPoints = eventPointsMany.allObjects as? [DistrictEventPoints] else {
            fatalError("Save DistrictRanking before accessing eventPoints")
        }
        return eventPoints
    }

    public var team: Team {
        guard let team = teamOne else {
            fatalError("Save DistrictRanking before accessing team")
        }
        return team
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DistrictRanking> {
        return NSFetchRequest<DistrictRanking>(entityName: DistrictRanking.entityName)
    }

    @NSManaged private var pointTotalNumber: NSNumber?
    @NSManaged private var rankNumber: NSNumber?
    @NSManaged private var rookieBonusNumber: NSNumber?
    @NSManaged private var districtOne: District?
    @NSManaged private var eventPointsMany: NSSet?
    @NSManaged private var teamOne: Team?

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
                                    #keyPath(DistrictRanking.districtOne.keyString), districtKey,
                                    #keyPath(DistrictRanking.teamOne.keyString), model.teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.teamOne = Team.insert(model.teamKey, in: context)

            ranking.pointTotalNumber = NSNumber(value: model.pointTotal)
            ranking.rankNumber = NSNumber(value: model.rank)

            if let rookieBonus = model.rookieBonus {
                ranking.rookieBonusNumber = NSNumber(value: rookieBonus)
            } else {
                ranking.rookieBonusNumber = nil
            }

            ranking.updateToManyRelationship(relationship: #keyPath(DistrictRanking.eventPointsMany), newValues: model.eventPoints.compactMap {
                return DistrictEventPoints.insert($0, in: context)
            })
        })
    }

}

extension DistrictRanking {

    // TODO: Audit the uses of this to see if we can have empty events when using this
    // TODO: Make sure we're doing this in a thread safe place
    public var sortedEventPoints: [DistrictEventPoints] {
        let eventPointsSet = getValue(\DistrictRanking.eventPoints)
        return eventPoints.sorted(by: { (lhs, rhs) -> Bool in
            guard let lhsStartDate = lhs.event.startDate else {
                return false
            }
            guard let rhsStartDate = rhs.event.startDate else {
                return false
            }
            return rhsStartDate > lhsStartDate
        })
    }

}

extension DistrictRanking: Orphanable {

    public var isOrphaned: Bool {
        return districtOne == nil
    }

}
