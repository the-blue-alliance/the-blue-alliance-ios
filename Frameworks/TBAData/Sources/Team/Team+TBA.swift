import CoreData
import Foundation
import MyTBAKit
import TBAKit

extension Team: Locatable, Surfable, Managed {

    public var fallbackNickname: String {
        let teamNumber: String = {
            if let teamNumber = self.teamNumber {
                return teamNumber.stringValue
            } else {
                return Team.trimFRCPrefix(key)
            }
        }()
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

    public var isOrphaned: Bool {
        // Team is a root object, so it should never be an orphan
        return false
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
