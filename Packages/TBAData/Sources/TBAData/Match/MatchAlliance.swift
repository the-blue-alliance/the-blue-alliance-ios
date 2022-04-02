import CoreData
import Foundation
import TBAKit

extension MatchAlliance {

    public var allianceKey: String {
        guard let allianceKey = getValue(\MatchAlliance.allianceKeyRaw) else {
            fatalError("Save MatchAlliance before accessing allianceKey")
        }
        return allianceKey
    }

    public var score: Int? {
        return getValue(\MatchAlliance.scoreRaw)?.intValue
    }

    public var dqTeams: NSOrderedSet {
        guard let dqTeams = getValue(\MatchAlliance.dqTeamsRaw) else {
            fatalError("Save MatchAlliance before accessing dqTeams")
        }
        return dqTeams
    }

    public var match: Match {
        guard let match = getValue(\MatchAlliance.matchRaw) else {
            fatalError("Save MatchAlliance before accessing match")
        }
        return match
    }

    public var surrogateTeams: NSOrderedSet {
        guard let surrogateTeams = getValue(\MatchAlliance.surrogateTeamsRaw) else {
            fatalError("Save MatchAlliance before accessing surrogateTeams")
        }
        return surrogateTeams
    }

    public var teams: NSOrderedSet {
        guard let teams = getValue(\MatchAlliance.teamsRaw) else {
            fatalError("Save MatchAlliance before accessing teams")
        }
        return teams
    }

    /**
     Returns team keys for DQ'd teams for the alliance.
     */
    public var dqTeamKeys: [String] {
        guard let dqTeams = dqTeams.array as? [Team] else {
            return []
        }
        return dqTeams.map({ $0.key })
    }

    /**
     Returns team keys for surrogate teams for the alliance.
     */
    public var surrogateTeamKeys: [String] {
        guard let surrogateTeams = surrogateTeams.array as? [Team] else {
            return []
        }
        return surrogateTeams.map({ $0.key })
    }

    /**
     Returns team keys for the alliance.
     */
    public var teamKeys: [String] {
        guard let teams = teams.array as? [Team] else {
            return []
        }
        return teams.map({ $0.key })
    }

}

@objc(MatchAlliance)
public class MatchAlliance: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchAlliance> {
        return NSFetchRequest<MatchAlliance>(entityName: MatchAlliance.entityName)
    }

    @NSManaged var allianceKeyRaw: String?
    @NSManaged var scoreRaw: NSNumber?
    @NSManaged var dqTeamsRaw: NSOrderedSet?
    @NSManaged var matchRaw: Match?
    @NSManaged var surrogateTeamsRaw: NSOrderedSet?
    @NSManaged var teamsRaw: NSOrderedSet?

}

extension MatchAlliance: Managed {

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
                                    #keyPath(MatchAlliance.allianceKeyRaw), allianceKey,
                                    #keyPath(MatchAlliance.matchRaw.keyRaw), matchKey)

        return findOrCreate(in: context, matching: predicate) { (matchAlliance) in
            // Required: allianceKey, score, teams
            matchAlliance.allianceKeyRaw = allianceKey

            // Match scores for unplayed matches are returned as -1 from the API
            if model.score > -1 {
                matchAlliance.scoreRaw = NSNumber(value: model.score)
            } else {
                matchAlliance.scoreRaw = nil
            }

            matchAlliance.teamsRaw = NSOrderedSet(array: model.teams.map {
                return Team.insert($0, in: context)
            })

            if let surrogateTeams = model.surrogateTeams {
                matchAlliance.surrogateTeamsRaw = NSOrderedSet(array: surrogateTeams.map {
                    return Team.insert($0, in: context)
                })
            } else {
                matchAlliance.surrogateTeamsRaw = nil
            }

            if let dqTeams = model.dqTeams {
                matchAlliance.dqTeamsRaw = NSOrderedSet(array: dqTeams.map {
                    return Team.insert($0, in: context)
                })
            } else {
                matchAlliance.dqTeamsRaw = nil
            }
        }
    }

}

extension MatchAlliance: Orphanable {

    public var isOrphaned: Bool {
        return matchRaw == nil
    }

}
