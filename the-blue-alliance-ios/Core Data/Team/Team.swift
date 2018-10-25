import Foundation
import TBAKit
import CoreData

extension Team: Locatable, Managed {

    var fallbackNickname: String {
        return "Team \(teamNumber!.stringValue)"
    }

    static func trimFRCPrefix(_ key: String) -> String {
        return key.prefixTrim("frc")
    }

    /**
     A TeamKey for the Team object.

     This may seem backwards, providing a TeamKey from a Team, but since TeamAtEventViewController doesn't handle either a Team *or* a TeamKey, we need to pull a TeamKey for controllers that have full Team objects (ex: TeamsViewController)
     */
    var teamKey: TeamKey {
        return TeamKey.insert(withKey: key!, in: managedObjectContext!)
    }

    /**
     Insert a Team with values from a TBAKit Team model in to the managed object context.

     - Parameter model: The TBAKit Team representation to set values from.

     - Parameter context: The NSManagedContext to insert the Favorite in to.

     - Returns: The inserted Team.
     */
    @discardableResult
    static func insert(_ model: TBATeam, in context: NSManagedObjectContext) -> Team {
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(Team.key),
                                    model.key)

        return findOrCreate(in: context, matching: predicate) { (team) in
            // Required: key, name, teamNumber, rookieYear
            team.address = model.address
            team.city = model.city
            team.country = model.country
            team.gmapsPlaceID = model.gmapsPlaceID
            team.gmapsURL = model.gmapsURL
            team.homeChampionship = model.homeChampionship
            team.key = model.key
            team.lat = model.lat as NSNumber?
            team.lng = model.lng as NSNumber?
            team.locationName = model.locationName
            team.motto = model.motto
            team.name = model.name
            team.nickname = model.nickname
            team.postalCode = model.postalCode
            team.rookieYear = model.rookieYear as NSNumber
            team.stateProv = model.stateProv
            team.teamNumber = model.teamNumber as NSNumber
            team.website = model.website
            team.homeChampionship = model.homeChampionship
        }
    }

    /**
     Insert an array of Teams with values from a TBAKit Team models in to the managed object context. This method manages setting up an Event and Team relationship.

     - Parameter teams: The TBAKit Team representations to set values from.

     - Parameter context: The NSManagedContext to insert the Favorite in to.

     - Returns: The inserted Teams.
     */
    @discardableResult
    static func insert(_ teams: [TBATeam], event: Event, in context: NSManagedObjectContext) -> [Team] {
        let teams = teams.map({
            return Team.insert($0, in: context)
        })
        event.teams = Set(teams) as NSSet
        return teams
    }

    static func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, [TBATeam]) -> Void, completion: @escaping (Error?) -> Void) -> URLSessionDataTask {
        return fetchAllTeams(taskChanged: taskChanged, page: 0, completion: completion)
    }

    static private func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, [TBATeam]) -> Void, page: Int, completion: @escaping (Error?) -> Void) -> URLSessionDataTask {
        // TODO: This is problematic, and doesn't handle 304's properly
        return TBAKit.sharedKit.fetchTeams(page: page, completion: { (teams, error) in
            if let error = error {
                completion(error)
                return
            }

            guard let teams = teams else {
                completion(nil)
                return
            }

            if teams.isEmpty {
                completion(nil)
            } else {
                taskChanged(self.fetchAllTeams(taskChanged: taskChanged, page: page + 1, completion: completion), teams)
            }
        })
    }

}
