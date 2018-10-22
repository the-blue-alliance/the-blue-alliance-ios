import Foundation
import CoreData
import TBAKit

extension DistrictEventPoints: Managed {

    static func insert(_ model: TBADistrictEventPoints, event contextEvent: Event, in context: NSManagedObjectContext) -> DistrictEventPoints {
        let event = context.object(with: contextEvent.objectID) as! Event
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(DistrictEventPoints.event.key), event.key!,
                                    #keyPath(DistrictEventPoints.teamKey.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate) { (eventPoints) in
            eventPoints.teamKey = TeamKey.insert(withKey: model.teamKey, in: context)
            eventPoints.event = event

            eventPoints.alliancePoints = model.alliancePoints as NSNumber
            eventPoints.awardPoints = model.awardPoints as NSNumber
            eventPoints.districtCMP = model.districtCMP as NSNumber?
            eventPoints.elimPoints = model.elimPoints as NSNumber
            eventPoints.qualPoints = model.qualPoints as NSNumber
            eventPoints.total = model.total as NSNumber
        }
    }

}
