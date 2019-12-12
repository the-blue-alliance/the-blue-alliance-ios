import CoreData
import Foundation
import TBAKit

@objc(DistrictEventPoints)
public class DistrictEventPoints: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DistrictEventPoints> {
        return NSFetchRequest<DistrictEventPoints>(entityName: "DistrictEventPoints")
    }

    @NSManaged public fileprivate(set) var alliancePoints: Int16
    @NSManaged public fileprivate(set) var awardPoints: Int16
    @NSManaged public fileprivate(set) var districtCMP: NSNumber?
    @NSManaged public fileprivate(set) var elimPoints: Int16
    @NSManaged public fileprivate(set) var qualPoints: Int16
    @NSManaged public fileprivate(set) var total: Int16
    @NSManaged public fileprivate(set) var districtRanking: DistrictRanking?
    @NSManaged public fileprivate(set) var event: Event
    @NSManaged public fileprivate(set) var team: Team

}

extension DistrictEventPoints {

    /**
     Insert a District Event Points with values from a TBAKit District Event Points model in to the managed object context.

     - Important: Method does not setup a relationship between a DistrictEventPoints and a DistrictRanking.

     - Parameter model: The TBAKit District Event Points representation to set values from.

     - Parameter context: The NSManagedContext to insert the District Event Points in to.

     - Returns: The inserted District Event Points.
     */
    public static func insert(_ model: TBADistrictEventPoints, in context: NSManagedObjectContext) -> DistrictEventPoints {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(DistrictEventPoints.event.key), model.eventKey,
                                    #keyPath(DistrictEventPoints.team.key), model.teamKey)

        return findOrCreate(in: context, matching: predicate) { (eventPoints) in
            eventPoints.team = Team.insert(model.teamKey, in: context)
            eventPoints.event = Event.insert(model.eventKey, in: context)

            eventPoints.alliancePoints = Int16(model.alliancePoints)
            eventPoints.awardPoints = Int16(model.awardPoints)
            if let districtCMP = model.districtCMP {
                eventPoints.districtCMP = NSNumber(value: districtCMP)
            } else {
                eventPoints.districtCMP = nil
            }
            eventPoints.elimPoints = Int16(model.elimPoints)
            eventPoints.qualPoints = Int16(model.qualPoints)
            eventPoints.total = Int16(model.total)
        }
    }

}
