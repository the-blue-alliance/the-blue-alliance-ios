import Foundation
import CoreData
import TBAKit

extension DistrictRanking {

    public var pointTotal: Int {
        guard let pointTotal = getValue(\DistrictRanking.pointTotalRaw)?.intValue else {
            fatalError("Save DistrictRanking before accessing pointTotal")
        }
        return pointTotal
    }

    public var rank: Int {
        guard let rank = getValue(\DistrictRanking.rankRaw)?.intValue else {
            fatalError("Save DistrictRanking before accessing rank")
        }
        return rank
    }

    public var rookieBonus: Int? {
        return getValue(\DistrictRanking.rookieBonusRaw)?.intValue
    }

    public var district: District {
        guard let district = getValue(\DistrictRanking.districtRaw) else {
            fatalError("Save DistrictRanking before accessing district")
        }
        return district
    }

    public var eventPoints: [DistrictEventPoints] {
        guard let eventPointsMany = getValue(\DistrictRanking.eventPointsRaw),
            let eventPoints = eventPointsMany.allObjects as? [DistrictEventPoints] else {
                fatalError("Save DistrictRanking before accessing eventPoints")
        }
        return eventPoints
    }

    public var team: Team {
        guard let team = getValue(\DistrictRanking.teamRaw) else {
            fatalError("Save DistrictRanking before accessing team")
        }
        return team
    }

    // TODO: Audit the uses of this to see if we can have empty events when using this
    public var sortedEventPoints: [DistrictEventPoints] {
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

@objc(DistrictRanking)
public class DistrictRanking: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DistrictRanking> {
        return NSFetchRequest<DistrictRanking>(entityName: DistrictRanking.entityName)
    }

    @NSManaged var pointTotalRaw: NSNumber?
    @NSManaged var rankRaw: NSNumber?
    @NSManaged var rookieBonusRaw: NSNumber?
    @NSManaged var districtRaw: District?
    @NSManaged var eventPointsRaw: NSSet?
    @NSManaged var teamRaw: Team?

}

// MARK: Generated accessors for eventPointsRaw
extension DistrictRanking {

    @objc(addEventPointsRawObject:)
    @NSManaged func addToEventPointsRaw(_ value: DistrictEventPoints)

    @objc(removeEventPointsRawObject:)
    @NSManaged func removeFromEventPointsRaw(_ value: DistrictEventPoints)

    @objc(addEventPointsRaw:)
    @NSManaged func addToEventPointsRaw(_ values: NSSet)

    @objc(removeEventPointsRaw:)
    @NSManaged func removeFromEventPointsRaw(_ values: NSSet)

}

extension DistrictRanking {

    public static func districtPredicate(districtKey: String) -> NSPredicate {
        return NSPredicate(format: "%K.%K == %@",
                           #keyPath(DistrictRanking.districtRaw), #keyPath(District.keyRaw), districtKey)
    }

    public static func teamSearchPredicate(searchText: String) -> NSPredicate {
        return Team.searchKeyPathPredicate(
            nicknameKeyPath: #keyPath(DistrictRanking.teamRaw.nicknameRaw),
            teamNumberKeyPath: #keyPath(DistrictRanking.teamRaw.teamNumberRaw.stringValue),
            cityKeyPath: #keyPath(DistrictRanking.teamRaw.cityRaw),
            searchText: searchText
        )
    }

    public static func rankSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(DistrictRanking.rankRaw), ascending: true)
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
                                    #keyPath(DistrictRanking.districtRaw.keyRaw), districtKey,
                                    #keyPath(DistrictRanking.teamRaw.keyRaw), model.teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.teamRaw = Team.insert(model.teamKey, in: context)

            ranking.pointTotalRaw = NSNumber(value: model.pointTotal)
            ranking.rankRaw = NSNumber(value: model.rank)

            if let rookieBonus = model.rookieBonus {
                ranking.rookieBonusRaw = NSNumber(value: rookieBonus)
            } else {
                ranking.rookieBonusRaw = nil
            }

            ranking.updateToManyRelationship(relationship: #keyPath(DistrictRanking.eventPointsRaw), newValues: model.eventPoints.compactMap {
                return DistrictEventPoints.insert($0, in: context)
            })
        })
    }

}

extension DistrictRanking: Orphanable {

    public var isOrphaned: Bool {
        return districtRaw == nil
    }

}
