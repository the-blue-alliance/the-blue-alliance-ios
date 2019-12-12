import CoreData
import MyTBAKit
import TBAKit
import TBAUtils

// https://github.com/the-blue-alliance/the-blue-alliance/blob/1324e9e5b7c4ab21315bd00a768112991bada108/models/match.py#L25
public enum MatchCompLevel: String, CaseIterable {
    case qualification = "qm"
    case eightfinal = "ef"
    case quarterfinal = "qf"
    case semifinal = "sf"
    case final = "f"

    public var sortOrder: Int {
        switch self {
        case .qualification:
            return 0
        case .eightfinal:
            return 1
        case .quarterfinal:
            return 2
        case .semifinal:
            return 3
        case .final:
            return 4
        }
    }

    // https://github.com/the-blue-alliance/the-blue-alliance/blob/1324e9e5b7c4ab21315bd00a768112991bada108/models/match.py#L34
    /**
     Human readable string representing the compLevel for the match.
     */
    public var level: String {
        switch self {
        case .qualification:
            return "Qualification"
        case .eightfinal:
            return "Octofinals"
        case .quarterfinal:
            return "Quarterfinals"
        case .semifinal:
            return "Semifinals"
        case .final:
            return "Finals"
        }
    }

    // https://github.com/the-blue-alliance/the-blue-alliance/blob/1324e9e5b7c4ab21315bd00a768112991bada108/models/match.py#L27
    /**
     Abbreviated human readable string representing the compLevel for the match.
     */
    public var levelShort: String {
        switch self {
        case .qualification:
            return "Quals"
        case .eightfinal:
            return "Eighths"
        case .quarterfinal:
            return "Quarters"
        case .semifinal:
            return "Semis"
        case .final:
            return "Finals"
        }
    }

}

extension Match {

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Match.key), key)
    }

    public static func forKey(_ key: String, in context: NSManagedObjectContext) -> Match? {
        let predicate = Match.predicate(key: key)
        return Match.findOrFetch(in: context, matching: predicate)
    }

    /**
     Returns the MatchCompLevel for the Match's compLevelString.
     */
    public var compLevel: MatchCompLevel? {
        guard let compLevel = MatchCompLevel(rawValue: compLevelString) else {
            return nil
        }
        return compLevel
    }

    /**
     Start time for the match, actual or a guess. In order
     - Returns actual start time for the match
     - Returns predicted start time for the match
     - Returns scheduled start time for the match
     */
    public var startTime: NSNumber? {
        if let actualTime = actualTime {
            return actualTime
        } else if let predictedTime = predictedTime {
            return predictedTime
        } else if let time = time {
            return time
        } else {
            return nil
        }
    }

    /**
     The formatted Match startTime.
     */
    public var startTimeString: String? {
        guard let startTime = startTime else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE h:mm a"

        let date = Date(timeIntervalSince1970: startTime.doubleValue)
        return dateFormatter.string(from: date)
    }

    /**
     Returns the alliance with an allianceKey of 'red'.
     */
    public var redAlliance: MatchAlliance? {
        return alliance(with: "red")
    }

    /**
     Returns the team keys for the red alliance.
     */
    public var redAllianceTeamKeys: [String] {
        return redAlliance?.teamKeys ?? []
    }

    /**
     Returns the team numbers (trimmed team keys) for the red alliance.
     */
    public var redAllianceTeamNumbers: [String] {
        return redAllianceTeamKeys.map({ Team.trimFRCPrefix($0) })
    }

    /**
     Returns the alliance with an allianceKey of 'blue'.
     */
    public var blueAlliance: MatchAlliance? {
        return alliance(with: "blue")
    }

    /**
     Returns the team keys for the blue alliance.
     */
    public var blueAllianceTeamKeys: [String] {
        return blueAlliance?.teamKeys ?? []
    }

    /**
     Returns the team numbers (trimmed team keys) for the blue alliance.
     */
    public var blueAllianceTeamNumbers: [String] {
        return blueAllianceTeamKeys.map({ Team.trimFRCPrefix($0) })
    }
    
    /**
     Returns the team keys for all alliances
    */
    public var teams: [Team] {
        guard let alliances = alliances?.allObjects as? [MatchAlliance] else {
            return []
        }
        return alliances.reduce([], { $0 + ($1.teams.array as? [Team] ?? []) })
    }

    /**
    Returns the team keys that were DQ'd in this match - not specifically any alliance
    */
    public var dqTeamKeys: [String] {
        return (blueAlliance?.dqTeamKeys ?? []) + (redAlliance?.dqTeamKeys ?? [])
    }

    private func alliance(with allianceKey: String) -> MatchAlliance? {
        return (alliances?.allObjects as? [MatchAlliance])?.first(where: { $0.allianceKey == allianceKey })
    }

    public var friendlyName: String {
        switch compLevel {
        case .none:
            return "Match \(matchNumber)"
        case .some(let compLevel):
            if compLevel == .qualification {
                return "\(compLevel.levelShort) \(matchNumber)"
            } else {
                return "\(compLevel.levelShort) \(setNumber)-\(matchNumber)"
            }
        }
    }

}

extension Match: Managed {

    public var isOrphaned: Bool {
        guard let managedObjectContext = managedObjectContext else {
            return true
        }

        // Match is orphaned if it isn't associated with an Event and isn't associated with a myTBA object
        let myTBAPredicate = NSPredicate(format: "%K == %@",
                                         #keyPath(MyTBAEntity.modelKey), key)
        let myTBAObject = MyTBAEntity.findOrFetch(in: managedObjectContext, matching: myTBAPredicate)

        return event == nil && myTBAObject == nil
    }

    override public func prepareForDeletion() {
        super.prepareForDeletion()

        (videos?.allObjects as? [MatchVideo])?.forEach({
            if $0.matches.onlyObject(self) {
                // Match Video will become an orphan - delete
                managedObjectContext?.delete($0)
            } else {
                $0.removeFromMatches(self)
            }
        })
    }

}


extension Match: MyTBASubscribable {

    public var modelKey: String {
        return getValue(\Match.key)
    }

    public var modelType: MyTBAModelType {
        return .match
    }

    public static var notificationTypes: [NotificationType] {
        return [
            NotificationType.upcomingMatch,
            NotificationType.matchScore,
            NotificationType.matchVideo
        ]
    }

}
