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
     Insert Teams for a page with values from TBAKit Team models in to the managed object context.

     This method manages deleting orphaned Teams for a page.

     - Parameter teams: The TBAKit Team representations to set values from.

     - Parameter page: The page for the Teams.

     - Parameter context: The NSManagedContext to insert the Event in to.
     */
    static func insert(_ teams: [TBATeam], page: Int, in context: NSManagedObjectContext) {
        /**
         Pages are sets of 500 teams
         Page 0: Teams 0-499
         Page 1: Teams 500-999
         Page 2: Teams 1000-1499
         */

        // Fetch all of the previous Teams for this page
        let oldTeams = Team.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K >= %ld AND %K < %ld",
                                       #keyPath(Team.teamNumber), (page * 500),
                                       #keyPath(Team.teamNumber), ((page + 1) * 500))
        }

        // Insert new Teams for this page
        let teams = teams.map({
            return Team.insert($0, in: context)
        })

        // Delete orphaned Teams for this year
        Set(oldTeams).subtracting(Set(teams)).forEach({
            context.delete($0)
        })
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
     Insert Events with values from TBAKit Event models in to the managed object context.

     This method manages setting up an Team's relationship to Events.

     - Parameter events: The TBAKit Event representations to set values from.
     */
    func insert(_ events: [TBAEvent]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        self.events = NSSet(array: events.map({
            return Event.insert($0, in: managedObjectContext)
        }))
    }

    /**
     Insert an array of Team Media with values from TBAKit Media models for a given year in to the managed object context.

     This method manages setting up a Team Media and Team relationship and deleting orphaned Team Media objects.

     This method works slightly differently from other insert array methods, since we need to filter by a Team's relationship to Team Media and the year. If we were to use updateToManyRelationship we would remove the relationship between other year's Team Media and this Team, without deleting the Team Media.

     - Parameter media: The TBAKit Media representations to set values from.

     - Parameter year: The year the Team Media relates to.
     */
    func insert(_ media: [TBAMedia], year: Int) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        // Fetch all of the previous TeamMedia for this Team and year
        let oldMedia = TeamMedia.fetch(in: managedObjectContext) {
            $0.predicate = NSPredicate(format: "%K == %@ AND %K == %ld",
                                       #keyPath(TeamMedia.team.key), key!,
                                       #keyPath(TeamMedia.year), year)
        }


        // Insert new TeamMedia for this year
        let media = media.map({ (model: TBAMedia) -> TeamMedia in
            let m = TeamMedia.insert(model, year: year, in: managedObjectContext)
            addToMedia(m)
            return m
        })

        // Delete orphaned TeamMedia for this Event
        Set(oldMedia).subtracting(Set(media)).forEach({
            managedObjectContext.delete($0)
        })
    }

    var isOrphaned: Bool {
        // Team is a root object, so it should never be an orphan
        return false
    }

    // TODO: What the fuck move these methods OUT
    static func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, Int, [TBATeam]) -> Void, completion: @escaping (Error?) -> Void) -> URLSessionDataTask {
        return fetchAllTeams(taskChanged: taskChanged, page: 0, completion: completion)
    }

    static private func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, Int, [TBATeam]) -> Void, page: Int, completion: @escaping (Error?) -> Void) -> URLSessionDataTask {
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
                taskChanged(self.fetchAllTeams(taskChanged: taskChanged, page: page + 1, completion: completion), page, teams)
            }
        })
    }

}
