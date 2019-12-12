import CoreData
import Foundation
import TBAKit

@objc(Match)
public class Match: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Match> {
        return NSFetchRequest<Match>(entityName: "Match")
    }

    @NSManaged public fileprivate(set) var actualTime: NSNumber?
    @NSManaged public fileprivate(set) var breakdown: [String: Any]?
    @NSManaged public fileprivate(set) var compLevelSortOrder: NSNumber?
    @NSManaged public fileprivate(set) var compLevelString: String
    @NSManaged public fileprivate(set) var key: String
    @NSManaged public fileprivate(set) var matchNumber: Int16
    @NSManaged public fileprivate(set) var postResultTime: NSNumber?
    @NSManaged public fileprivate(set) var predictedTime: NSNumber?
    @NSManaged public fileprivate(set) var setNumber: Int16
    @NSManaged public fileprivate(set) var time: NSNumber?
    @NSManaged public fileprivate(set) var winningAlliance: String?
    @NSManaged public fileprivate(set) var alliances: NSSet?
    @NSManaged public fileprivate(set) var event: Event
    @NSManaged public fileprivate(set) var videos: NSSet?

}

extension Match {

    /**
     Insert a Match with values from a TBAKit Match model in to the managed object context.

     This method will manage the deletion of oprhaned Match Alliances and Match Videos on a Match.

     - Parameter model: The TBAKit Match representation to set values from.

     - Parameter context: The NSManagedContext to insert the Match in to.

     - Returns: The inserted Match.
     */
    @discardableResult
    public static func insert(_ model: TBAMatch, in context: NSManagedObjectContext) -> Match {
        let predicate = Match.predicate(key: model.key)

        return findOrCreate(in: context, matching: predicate) { (match) in
            // Required: compLevel, key, matchNumber, setNumber, event
            match.key = model.key
            match.compLevelString = model.compLevel

            // When adding a new MatchCompLevel, models will need a migration to update this
            if let compLevel = MatchCompLevel(rawValue: model.compLevel) {
                match.compLevelSortOrder = compLevel.sortOrder as NSNumber
            } else {
                match.compLevelSortOrder = nil
            }

            match.updateToOneRelationship(relationship: #keyPath(Match.event), newValue: model.eventKey) {
                return Event.insert($0, in: context)
            }

            match.setNumber = Int16(model.setNumber)
            match.matchNumber = Int16(model.matchNumber)

            match.updateToManyRelationship(relationship: #keyPath(Match.alliances), newValues: model.alliances?.map({ (key: String, value: TBAMatchAlliance) -> MatchAlliance in
                return MatchAlliance.insert(value, allianceKey: key, matchKey: model.key, in: context)
            }))

            match.winningAlliance = model.winningAlliance

            match.time = model.time as NSNumber?
            match.actualTime = model.actualTime as NSNumber?
            match.predictedTime = model.predictedTime as NSNumber?
            match.postResultTime = model.postResultTime as NSNumber?
            match.breakdown = model.breakdown

            match.updateToManyRelationship(relationship: #keyPath(Match.videos), newValues: model.videos?.map({
                return MatchVideo.insert($0, in: context)
            }))
        }
    }

}

