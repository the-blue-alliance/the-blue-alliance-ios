import Foundation
import TBAKit
import CoreData

extension MatchAlliance: Managed {

    var teams: [String] {
        return teamsJoined!.split(separator: ",").map({ String($0) })
    }

    var surrogateTeams: [String]? {
        return surrogateTeamsJoined?.split(separator: ",").map({ String($0) })
    }

    var dqTeams: [String]? {
        return dqTeamsJoined?.split(separator: ",").map({ String($0) })
    }

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

            // These are stored as comma separated strings so they can be queried against with predicates
            // If they were stored as Transformables, they're stored as binary blobs, and can't be used with predicates
            // There's probably a way to do this with value transformers but https://stackoverflow.com/a/21815411
            matchAlliance.teamsJoined = model.teams.joined(separator: ",")
            matchAlliance.surrogateTeamsJoined = model.surrogateTeams?.joined(separator: ",")
            matchAlliance.dqTeamsJoined = model.dqTeams?.joined(separator: ",")
        }
    }

}
