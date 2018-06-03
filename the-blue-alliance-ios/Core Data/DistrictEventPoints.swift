import Foundation
import CoreData
import TBAKit

extension DistrictEventPoints: Managed {
    
    static func insert(with model: TBADistrictEventPoints, for event: Event, in context: NSManagedObjectContext) -> DistrictEventPoints {
        guard let teamKey = model.teamKey else {
            fatalError("Need team key")
        }
        let team = Team.insert(withKey: teamKey, in: context)
        return insert(with: model, for: event, and: team, in: context)
    }
    
    static func insert(with model: TBADistrictEventPoints, for event: Event, and team: Team, in context: NSManagedObjectContext) -> DistrictEventPoints {
        let predicate = NSPredicate(format: "team == %@ AND event == %@", team, event)
        return findOrCreate(in: context, matching: predicate) { (eventPoints) in
            eventPoints.team = team
            eventPoints.event = event
            
            eventPoints.alliancePoints = Int16(model.alliancePoints)
            eventPoints.awardPoints = Int16(model.awardPoints)
            
            if let districtCMP = model.districtCMP {
                eventPoints.districtCMP = NSNumber(booleanLiteral: districtCMP)
            }
            
            eventPoints.elimPoints = Int16(model.elimPoints)
            eventPoints.qualPoints = Int16(model.qualPoints)
            eventPoints.total = Int16(model.total)
        }
    }

}
