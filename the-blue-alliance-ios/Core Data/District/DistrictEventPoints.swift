import Foundation
import CoreData
import TBAKit

extension DistrictEventPoints: Managed {

    static func insert(_ model: TBADistrictEventPoints, event: Event, in context: NSManagedObjectContext) -> DistrictEventPoints {
        let event = context.object(with: event.objectID) as! Event
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(DistrictEventPoints.event.key), event.key!,
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

    // TODO: Insert for Event... (~this needs tests~)
    @discardableResult
    static func insert(_ points: [TBADistrictEventPoints], event: Event, in context: NSManagedObjectContext) -> [DistrictEventPoints] {
        let event = context.object(with: event.objectID) as! Event
        let points = points.map({
            return DistrictEventPoints.insert($0, event: event, in: context)
        })
        updateToManyRelationship(relationship: &event.points, newValues: points, matchingOrphans: { _ in
            // Rankings will never belong to more than one district, so this should always be true
            return true
        }, in: context)
        return points
    }

}
