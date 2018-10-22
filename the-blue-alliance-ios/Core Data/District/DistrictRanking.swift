import Foundation
import TBAKit
import CoreData

extension DistrictRanking: Managed {

    @discardableResult
    static func insert(_ model: TBADistrictRanking, district contextDistrict: District, in context: NSManagedObjectContext) -> DistrictRanking {
        let district = context.object(with: contextDistrict.objectID) as! District
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(DistrictRanking.district.key), district.key!,
                                    #keyPath(DistrictRanking.teamKey.key), model.teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.district = district
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
            updateToManyRelationship(relationship: &ranking.eventPoints, newValues: eventPoints, matchingOrphans: {
                return $0.districtRanking == ranking
            }, in: context)
        })
    }

}
