import CoreData
import Foundation
import MyTBAKit
import TBAKit

extension Team {

    /**
     Insert Teams for a page with values from TBAKit Team models in to the managed object context.

     This method manages deleting orphaned Teams for a page.

     - Parameter teams: The TBAKit Team representations to set values from.

     - Parameter page: The page for the Teams.

     - Parameter context: The NSManagedContext to insert the Event in to.
     */
    public static func insert(_ teams: [TBATeam], page: Int, in context: NSManagedObjectContext) {
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
        let teams = teams.map {
            return Team.insert($0, in: context)
        }

        // Delete orphaned Teams for this year
        Set(oldTeams).subtracting(Set(teams)).forEach({
            context.delete($0)
        })
    }

    // TODO: Rename to `team number nickname` maybe
    public var fallbackNickname: String {
        return "Team \(teamNumber)"
    }

    /**
     Returns an uppercased team number by removing the `frc` prefix on the key
     */
    public static func trimFRCPrefix(_ key: String) -> String {
        return key.trimPrefix("frc").uppercased()
    }

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Team.key), key)
    }

    /**
     Returns an NSPredicate for full Team objects - aka, they have all required API fields.
     This includes key, name, teamNumber, rookieYear
     */
    public static func populatedTeamsPredicate() -> NSPredicate {
        var keys = [#keyPath(Team.key),
                    #keyPath(Team.name),
                    #keyPath(Team.teamNumber),
                    #keyPath(Team.rookieYear)]
        let format = keys.map {
            return String("\($0) != nil")
        }.joined(separator: " && ")
        return NSPredicate(format: format)
    }

}

extension Team: Managed {

    public var isOrphaned: Bool {
        // Team is a root object, so it should never be an orphan
        return false
    }

}

extension Team: MyTBASubscribable {

    public var modelKey: String {
        return getValue(\Team.key)
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

extension Team: Locatable, Surfable {}
