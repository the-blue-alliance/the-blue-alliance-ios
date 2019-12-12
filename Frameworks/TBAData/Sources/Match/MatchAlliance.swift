import CoreData
import Foundation
import TBAKit

@objc(MatchAlliance)
public class MatchAlliance: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchAlliance> {
        return NSFetchRequest<MatchAlliance>(entityName: "MatchAlliance")
    }

    @NSManaged public fileprivate(set) var allianceKey: String
    @NSManaged public fileprivate(set) var score: NSNumber?
    @NSManaged public fileprivate(set) var dqTeams: NSOrderedSet?
    @NSManaged public fileprivate(set) var match: Match
    @NSManaged public fileprivate(set) var surrogateTeams: NSOrderedSet?
    @NSManaged public fileprivate(set) var teams: NSOrderedSet

}

extension MatchAlliance {

    /**
     Returns team keys for the alliance.
     */
    public var teamKeys: [String] {
        guard let teams = teams.array as? [Team] else {
            return []
        }
        return teams.map({ $0.key })
    }

    /**
     Returns team keys for DQ'd teams for the alliance.
     */
    public var dqTeamKeys: [String] {
        guard let dqTeams = dqTeams?.array as? [Team] else {
            return []
        }
        return dqTeams.map({ $0.key })
    }

    /**
     Insert a Match Alliance with values from a TBAKit Match Alliance model in to the managed object context.

     - Important: This method does not manage setting up a Match Alliance's relationship to a Match.

     - Parameter model: The TBAKit Match Alliance representation to set values from.

     - Parameter allianceKey: The `key` for the alliance - usually the alliance color (red, blue).

     - Parameter matchKey: The `key` for the Match the Match Alliance belongs to.

     - Parameter context: The NSManagedContext to insert the Match Alliance in to.

     - Returns: The inserted Match Alliance.
     */
    public static func insert(_ model: TBAMatchAlliance, allianceKey: String, matchKey: String, in context: NSManagedObjectContext) -> MatchAlliance {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(MatchAlliance.allianceKey), allianceKey,
                                    #keyPath(MatchAlliance.match.key), matchKey)

        return findOrCreate(in: context, matching: predicate) { (matchAlliance) in
            // Required: allianceKey, score, teams
            matchAlliance.allianceKey = allianceKey

            // Match scores for unplayed matches are returned as -1 from the API
            if model.score > -1 {
                matchAlliance.score = model.score as NSNumber
            } else {
                matchAlliance.score = nil
            }

            // Don't use updateToManyRelationship to set these up, since Team Key's will never be orphaned.
            // Additionally, updateToManyRelationship doesn't support ordered sets

            matchAlliance.teams = NSOrderedSet(array: model.teams.map {
                return Team.insert($0, in: context)
            })

            if let surrogateTeams = model.surrogateTeams {
                matchAlliance.surrogateTeams = NSOrderedSet(array: surrogateTeams.map {
                    return Team.insert($0, in: context)
                })
            } else {
                matchAlliance.surrogateTeams = nil
            }

            if let dqTeams = model.dqTeams {
                matchAlliance.dqTeams = NSOrderedSet(array: dqTeams.map {
                    return Team.insert($0, in: context)
                })
            } else {
                matchAlliance.dqTeams = nil
            }
        }
    }

}

