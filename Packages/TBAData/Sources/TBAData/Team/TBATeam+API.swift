import CoreData
import Foundation
import TBAKit

//extension Team {
//
//    public func avatar(year: Int) -> TeamMedia? {
//        let avatars = media.filter {
//            guard let type = $0.type else {
//                return false
//            }
//            return $0.year == year && type == .avatar
//        }
//        return avatars.first
//    }
//
//    public var yearsParticipated: [Int]? {
//        return getValue(\Team.yearsParticipatedRaw)?.sorted().reversed()
//    }
//
//}

extension TBATeam: Managed {

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(TBATeam.key), key)
    }

    /// (Async) Insert Teams with values from TBAKit Team models in to the managed object context.
    /// This method manages deleting orphaned Teams.
    /// - Parameters:
    ///   - teams: The TBAKit Team representations to set values from.
    ///   - context: The NSManagedContext to insert the Event in to.
    public static func insert(_ teams: [APITeam], in context: NSManagedObjectContext) async throws {
        // Fetch all of the previous Teams
        let oldTeams = try await TBATeam.fetch(in: context)

        // Insert new Teams for this page
        let teams = try await teams.asyncMap {
            try await TBATeam.insert($0, in: context)
        }

        // TODO: Should ONLY fail if all fail... right?

        // Delete orphaned Teams for this year
        let deleteTeams = Set(oldTeams).subtracting(Set(teams))
        for team in deleteTeams {
            await context.perform {
                context.delete(team)
            }
        }
    }

    /// (Async) Insert Teams for a page with values from TBAKit Team models in to the managed object context.
    /// This method manages deleting orphaned Teams for a page.
    /// - Parameters:
    ///   - teams: The TBAKit Team representations to set values from.
    ///   - page: The page for the Teams.
    ///   - context: The NSManagedContext to insert the Event in to.
    public static func insert(_ teams: [APITeam], page: Int, in context: NSManagedObjectContext) async throws {
         /// Pages are sets of 500 teams
         /// Page 0: Teams 0-499
         /// Page 1: Teams 500-999
         /// Page 2: Teams 1000-1499

        // Fetch all of the previous Teams for this page
        let oldTeams = try await TBATeam.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K >= %ld AND %K < %ld",
                                       #keyPath(TBATeam.teamNumber), (page * 500),
                                       #keyPath(TBATeam.teamNumber), ((page + 1) * 500))
        }

        // Insert new Teams for this page
        let teams = try await teams.asyncMap {
            try await TBATeam.insert($0, in: context)
        }

        // TODO: Should ONLY fail if all fail... right?

        // Delete orphaned Teams for this year
        let deleteTeams = Set(oldTeams).subtracting(Set(teams))
        for team in deleteTeams {
            await context.perform {
                context.delete(team)
            }
        }
    }

    /*
    /**
     Insert a Team with a specified key in to the managed object context.

     - Parameter key: The key for the Team.

     - Parameter context: The NSManagedContext to insert the Event in to.

     - Returns: The inserted Team.
     */
    public static func insert(_ key: String, in context: NSManagedObjectContext) -> TBATeam {
        let predicate = Team.predicate(key: key)
        return findOrCreate(in: context, matching: predicate) { (team) in
            team.keyRaw = key

            let teamNumberString = Team.trimFRCPrefix(key)
            if let teamNumber = Int(teamNumberString) {
                team.teamNumberRaw = NSNumber(value: teamNumber)
            }
        }
    }
    */

    /**
     Insert a Team with values from a TBAKit Team model in to the managed object context.

     - Parameter model: The TBAKit Team representation to set values from.

     - Parameter context: The NSManagedContext to insert the Favorite in to.

     - Returns: The inserted Team.
     */
    @discardableResult
    public static func insert(_ model: APITeam, in context: NSManagedObjectContext) async throws -> TBATeam {
        let predicate = TBATeam.predicate(key: model.key)
        return try await findOrCreate(in: context, matching: predicate) { (team) in
            team.address = model.address
            team.city = model.city
            team.country = model.country
            team.gmapsPlaceID = model.gmapsPlaceID
            team.gmapsURL = model.gmapsURL
            team.homeChampionship = model.homeChampionship
            team.key = model.key

            team.lat = {
                if let lat = model.lat {
                    return NSNumber(value: lat)
                }
                return nil
            }()
            team.lng = {
                if let lng = model.lng {
                    return NSNumber(value: lng)
                }
                return nil
            }()
            team.locationName = model.locationName
            team.name = model.name
            team.nickname = model.nickname
            team.postalCode = model.postalCode
            team.rookieYear = {
                if let rookieYear = model.rookieYear {
                    return NSNumber(value: rookieYear)
                }
                return nil
            }()
            team.schoolName = model.schoolName
            team.stateProv = model.stateProv
            team.teamNumber = NSNumber(value: model.teamNumber)
            team.website = model.website
            team.homeChampionship = model.homeChampionship
        }
    }

    /*
    /**
     Insert Events with values from TBAKit Event models in to the managed object context.

     This method manages setting up an Team's relationship to Events.

     - Parameter events: The TBAKit Event representations to set values from.
     */
    public func insert(_ events: [TBAEvent]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        self.eventsRaw = NSSet(array: events.map {
            return Event.insert($0, in: managedObjectContext)
        })
    }

    /**
     Insert an array of Team Media with values from TBAKit Media models for a given year in to the managed object context.

     This method manages setting up a Team Media and Team relationship and deleting orphaned Team Media objects.

     This method works slightly differently from other insert array methods, since we need to filter by a Team's relationship to Team Media and the year. If we were to use updateToManyRelationship we would remove the relationship between other year's Team Media and this Team, without deleting the Team Media.

     - Parameter media: The TBAKit Media representations to set values from.

     - Parameter year: The year the Team Media relates to.

     - Returns: The inserted Media.
     */
    @discardableResult
    public func insert(_ media: [TBAMedia], year: Int) -> [TeamMedia] {
        guard let managedObjectContext = managedObjectContext else {
            return []
        }

        // Fetch all of the previous TeamMedia for this Team and year
        let oldMedia = TeamMedia.fetch(in: managedObjectContext) {
            $0.predicate = TeamMedia.teamYearPrediate(teamKey: key, year: year)
        }


        // Insert new TeamMedia for this year
        let media = media.map {
            return TeamMedia.insert($0, year: year, in: managedObjectContext)
        }
        addToMediaRaw(NSSet(array: media))

        // Delete orphaned TeamMedia for this Event
        Set(oldMedia).subtracting(Set(media)).forEach({
            managedObjectContext.delete($0)
        })

        return media
    }

    /**
     Set the years participated for a Team.

     - Parameter years: The years participated for this Team.
     */
    public func setYearsParticipated(_ yearsParticipated: [Int]) {
        setValue(value: yearsParticipated, \Team.yearsParticipatedRaw)
    }
    */

}

//extension Team {
//
//    public static func districtPredicate(districtKey: String) -> NSPredicate {
//        return NSPredicate(format: "ANY %K.%K = %@",
//                           #keyPath(Team.districtsRaw), #keyPath(District.keyRaw), districtKey)
//    }
//
//    public static func eventPredicate(eventKey: String) -> NSPredicate {
//        return NSPredicate(format: "ANY %K.%K = %@",
//                           #keyPath(Team.eventsRaw), #keyPath(Event.keyRaw), eventKey)
//    }
//
//    public static func searchPredicate(searchText: String) -> NSPredicate {
//        return Team.searchKeyPathPredicate(
//            nicknameKeyPath: #keyPath(Team.nicknameRaw),
//            teamNumberKeyPath: #keyPath(Team.teamNumberRaw.stringValue),
//            cityKeyPath: #keyPath(Team.cityRaw),
//            searchText: searchText
//        )
//    }
//
//    public static func searchKeyPathPredicate(nicknameKeyPath: String, teamNumberKeyPath: String, cityKeyPath: String, searchText: String) -> NSPredicate {
//        return NSPredicate(format: "(%K contains[cd] %@ OR %K beginswith[cd] %@ OR %K contains[cd] %@)",
//                           nicknameKeyPath, searchText,
//                           teamNumberKeyPath, searchText,
//                           cityKeyPath, searchText)
//    }
//
//    public static func teamNumberSortDescriptor() -> NSSortDescriptor {
//        return NSSortDescriptor(key: #keyPath(Team.teamNumberRaw), ascending: true)
//    }
//
//    /**
//     Returns an uppercased team number by removing the `frc` prefix on the key
//     */
//    public static func trimFRCPrefix(_ key: String) -> String {
//        return key.trimPrefix("frc").uppercased()
//    }
//
//    /**
//     Returns an NSPredicate for full Team objects - aka, they have all required API fields.
//     This includes key, name, teamNumber
//     */
//    public static func populatedTeamsPredicate() -> NSPredicate {
//        let keys = [#keyPath(Team.keyRaw),
//                    #keyPath(Team.nameRaw)]
//        let format = keys.map {
//            return String("\($0) != nil")
//        }.joined(separator: " && ")
//        return NSPredicate(format: format)
//    }
//
//    /**
//     The team number name for the team
//     Ex: "Team 7332"
//     */
//    public var teamNumberNickname: String {
//        return "Team \(teamNumber)"
//    }
//
//}
//
//extension Team: Comparable {
//
//    public static func <(lhs: Team, rhs: Team) -> Bool {
//        return lhs.teamNumber < rhs.teamNumber
//    }
//
//}
//
//extension Team: MyTBASubscribable {
//
//    public var modelKey: String {
//        return key
//    }
//
//    public var modelType: MyTBAModelType {
//        return .team
//    }
//
//    public static var notificationTypes: [NotificationType] {
//        return [
//            NotificationType.upcomingMatch,
//            NotificationType.matchScore,
//            NotificationType.allianceSelection,
//            NotificationType.awards,
//            NotificationType.matchVideo
//        ]
//    }
//
//}
//
//extension Team: Locatable, Surfable {}
