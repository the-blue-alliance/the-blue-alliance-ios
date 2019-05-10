import CoreData
import Foundation
import MyTBAKit
import TBAKit

extension Team {

    var fallbackNickname: String {
        return "Team \(teamNumber!.stringValue)"
    }

    func avatar(year: Int) -> TeamMedia? {
        guard let media = media?.allObjects as? [TeamMedia] else {
            return nil
        }
        let avatars = media.filter {
            guard let mediaYear = $0.year?.intValue else {
                return false
            }
            guard let mediaType = $0.type else {
                return false
            }
            return year == mediaYear && mediaType == MediaType.avatar.rawValue
        }
        return avatars.first
    }

}

extension Team: Locatable, Surfable, Managed {

    /**
     Returns an uppercased team number by removing the `frc` prefix on the key
     */
    static func trimFRCPrefix(_ key: String) -> String {
        return key.trimPrefix("frc").uppercased()
    }

    /**
     A TeamKey for the Team object.

     This may seem backwards, providing a TeamKey from a Team, but since TeamAtEventViewController doesn't handle either a Team *or* a TeamKey, we need to pull a TeamKey for controllers that have full Team objects (ex: TeamsViewController)
     */
    var teamKey: TeamKey {
        let key = getValue(\Team.key!)
        return TeamKey.insert(withKey: key, in: managedObjectContext!)
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

    static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Team.key), key)
    }

    /**
     Insert a Team with values from a TBAKit Team model in to the managed object context.

     - Parameter model: The TBAKit Team representation to set values from.

     - Parameter context: The NSManagedContext to insert the Favorite in to.

     - Returns: The inserted Team.
     */
    @discardableResult
    static func insert(_ model: TBATeam, in context: NSManagedObjectContext) -> Team {
        let predicate = Team.predicate(key: model.key)

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

}


extension Team: MyTBASubscribable {

    public var modelKey: String {
        return getValue(\Team.key!)
    }

    public var modelType: MyTBAModelType {
        return .team
    }

    public static var notificationTypes: [NotificationType] {
        return [
            NotificationType.upcomingMatch,
            NotificationType.matchScore,
            NotificationType.allianceSelection,
            NotificationType.awards,
            NotificationType.matchVideo
        ]
    }

}
