import Foundation
import TBAKit
import CoreData

extension MatchAlliance: Managed {

    static func insert(with model: TBAMatchAlliance, allianceKey: String, for match: Match, in context: NSManagedObjectContext) -> MatchAlliance {
        let predicate = NSPredicate(format: "allianceKey == %@ AND match == %@", allianceKey, match)
        return findOrCreate(in: context, matching: predicate) { (matchAlliance) in
            // Required: allianceKey, score, teams
            matchAlliance.allianceKey = allianceKey

            // Match scores for unplayed matches are returned as -1 from the API
            if model.score > -1 {
                matchAlliance.score = NSNumber(value: model.score)
            } else {
                matchAlliance.score = nil
            }

            matchAlliance.teams = NSOrderedSet(array: model.teams.map({ (key) -> TeamKey in
                return TeamKey.insert(withKey: key, in: context)
            }))

            if let surrogateTeams = model.surrogateTeams {
                matchAlliance.surrogateTeams = NSOrderedSet(array: surrogateTeams.map({ (key) -> TeamKey in
                    return TeamKey.insert(withKey: key, in: context)
                }))
            } else {
                matchAlliance.surrogateTeams = nil
            }

            if let dqTeams = model.dqTeams {
                matchAlliance.dqTeams = NSOrderedSet(array: dqTeams.map({ (key) -> TeamKey in
                    return TeamKey.insert(withKey: key, in: context)
                }))
            } else {
                matchAlliance.dqTeams = nil
            }
        }
    }

}
