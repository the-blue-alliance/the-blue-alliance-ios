import CoreData
import Foundation
import TBAKit

@objc(MatchAlliance)
public class MatchAlliance: NSManagedObject {

    public var allianceKey: String {
        guard let allianceKey = allianceKeyString else {
            fatalError("Save MatchAlliance before accessing allianceKey")
        }
        return allianceKey
    }

    public var score: Int? {
        return scoreNumber?.intValue
    }

    public var match: Match {
        guard let match = matchOne else {
            fatalError("Save MatchAlliance before accessing match")
        }
        return match
    }

    public var teams: NSOrderedSet {
        guard let teams = teamsMany else {
            fatalError("Save MatchAlliance before accessing teams")
        }
        return teams
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchAlliance> {
        return NSFetchRequest<MatchAlliance>(entityName: MatchAlliance.entityName)
    }

    @NSManaged private var allianceKeyString: String?
    @NSManaged private var scoreNumber: NSNumber?
    @NSManaged public private(set) var dqTeams: NSOrderedSet?
    @NSManaged private var matchOne: Match?
    @NSManaged public private(set) var surrogateTeams: NSOrderedSet?
    @NSManaged private var teamsMany: NSOrderedSet?

}

extension MatchAlliance: Managed {

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
                                    #keyPath(MatchAlliance.allianceKeyString), allianceKey,
                                    #keyPath(MatchAlliance.matchOne.keyString), matchKey)

        return findOrCreate(in: context, matching: predicate) { (matchAlliance) in
            // Required: allianceKey, score, teams
            matchAlliance.allianceKeyString = allianceKey

            // Match scores for unplayed matches are returned as -1 from the API
            if model.score > -1 {
                matchAlliance.scoreNumber = NSNumber(value: model.score)
            } else {
                matchAlliance.scoreNumber = nil
            }

            matchAlliance.teamsMany = NSOrderedSet(array: model.teams.map {
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

extension MatchAlliance {
    
}

extension MatchAlliance: Orphanable {

    public var isOrphaned: Bool {
        return matchOne == nil
    }

}
