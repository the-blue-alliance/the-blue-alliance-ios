import Foundation
import TBAKit
import CoreData

extension DistrictRanking: Managed {

    static func insert(with model: TBADistrictRanking, for district: District, in context: NSManagedObjectContext) -> DistrictRanking {
        let teamKey = TeamKey.insert(withKey: model.teamKey, in: context)
        let predicate = NSPredicate(format: "district == %@ AND teamKey == %@", district, teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (ranking) in
            ranking.district = district
            ranking.teamKey = teamKey

            ranking.pointTotal = Int16(model.pointTotal)
            ranking.rank = Int16(model.rank)

            if let rookieBonus = model.rookieBonus {
                ranking.rookieBonus = Int16(rookieBonus)
            }

            ranking.eventPoints = Set(model.eventPoints.compactMap({ (modelPoints) -> DistrictEventPoints? in
                guard let eventKey = modelPoints.eventKey else {
                    return nil
                }

                let eventPredicate = NSPredicate(format: "key == %@", eventKey)
                guard let event = Event.findOrFetch(in: context, matching: eventPredicate) else {
                    return nil
                }

                return DistrictEventPoints.insert(with: modelPoints, for: event, and: teamKey, in: context)
            })) as NSSet
        })
    }

}
