import CoreData
import Foundation
import MyTBAKit
import TBAKit
import TBAUtils

@objc(Match)
public class Match: NSManagedObject {

    public var actualTime: Int? {
        return actualTimeNumber?.intValue
    }

    public var compLevelSortOrder: Int? {
        return compLevelSortOrderNumber?.intValue
    }

    /**
     Returns the MatchCompLevel for the Match's compLevelString.
     */
    public var compLevel: MatchCompLevel? {
        guard let compLevelString = compLevelString else {
            fatalError("Save Match before accessing compLevel")
        }
        guard let compLevel = MatchCompLevel(rawValue: compLevelString) else {
            return nil
        }
        return compLevel
    }

    public var key: String {
        guard let key = keyString else {
            fatalError("Save Match before accessing key")
        }
        return key
    }

    public var matchNumber: Int {
        guard let matchNumber = matchNumberNumber?.intValue else {
            fatalError("Save Match before accessing matchNumber")
        }
        return matchNumber
    }

    public var postResultTime: Int? {
        return postResultTimeNumber?.intValue
    }

    public var predictedTime: Int? {
        return predictedTimeNumber?.intValue
    }

    public var setNumber: Int {
        guard let setNumber = setNumberNumber?.intValue else {
            fatalError("Save Match before accessing setNumber")
        }
        return setNumber
    }

    public var time: Int? {
        return timeNumber?.intValue
    }

    public var alliances: [MatchAlliance] {
        guard let alliancesMany = alliancesMany, let alliances = alliancesMany.allObjects as? [MatchAlliance] else {
            return []
        }
        return alliances
    }

    public var event: Event {
        guard let event = eventOne else {
            fatalError("Save Match before accessing event")
        }
        return event
    }

    public var videos: [MatchVideo] {
        guard let videosMany = videosMany, let videos = videosMany.allObjects as? [MatchVideo] else {
            return []
        }
        return videos
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Match> {
        return NSFetchRequest<Match>(entityName: Match.entityName)
    }

    @NSManaged private var actualTimeNumber: NSNumber?
    @NSManaged private var breakdown: [String: Any]?
    @NSManaged private var compLevelSortOrderNumber: NSNumber?
    @NSManaged private var compLevelString: String?
    @NSManaged internal private(set) var keyString: String?
    @NSManaged private var matchNumberNumber: NSNumber?
    @NSManaged private var postResultTimeNumber: NSNumber?
    @NSManaged private var predictedTimeNumber: NSNumber?
    @NSManaged private var setNumberNumber: NSNumber?
    @NSManaged private var timeNumber: NSNumber?
    @NSManaged public private(set) var winningAlliance: String?
    @NSManaged private var alliancesMany: NSSet?
    @NSManaged private var eventOne: Event?
    @NSManaged private var videosMany: NSSet?

}

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

extension Match: Managed {

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Match.keyString), key)
    }

    /**
     Insert a Match with values from a TBAKit Match model in to the managed object context.

     This method will manage the deletion of oprhaned Match Alliances and Match Videos on a Match.

     - Parameter model: The TBAKit Match representation to set values from.

     - Parameter context: The NSManagedContext to insert the Match in to.

     - Returns: The inserted Match.
     */
    @discardableResult
    public static func insert(_ model: TBAMatch, in context: NSManagedObjectContext) -> Match {
        let predicate = Match.predicate(key: model.key)

        return findOrCreate(in: context, matching: predicate) { (match) in
            // Required: compLevel, key, matchNumber, setNumber, event
            match.keyString = model.key
            match.compLevelString = model.compLevel

            // When adding a new MatchCompLevel, models will need a migration to update this
            if let compLevel = MatchCompLevel(rawValue: model.compLevel) {
                match.compLevelSortOrderNumber = NSNumber(value: compLevel.sortOrder)
            } else {
                match.compLevelSortOrderNumber = nil
            }

            match.eventOne = Event.insert(model.eventKey, in: context)
            match.setNumberNumber = NSNumber(value: model.setNumber)
            match.matchNumberNumber = NSNumber(value: model.matchNumber)

            match.updateToManyRelationship(relationship: #keyPath(Match.alliancesMany), newValues: model.alliances?.map({ (key: String, value: TBAMatchAlliance) -> MatchAlliance in
                return MatchAlliance.insert(value, allianceKey: key, matchKey: model.key, in: context)
            }))

            match.winningAlliance = model.winningAlliance

            if let time = model.time {
                match.timeNumber = NSNumber(value: time)
            } else {
                match.timeNumber = nil
            }
            if let actualTime = model.actualTime {
                match.actualTimeNumber = NSNumber(value: actualTime)
            } else {
                match.actualTimeNumber = nil
            }
            if let predictedTime = model.predictedTime {
                match.predictedTimeNumber = NSNumber(value: predictedTime)
            } else {
                match.predictedTimeNumber = nil
            }
            if let postResultTime = model.postResultTime {
                match.postResultTimeNumber = NSNumber(value: postResultTime)
            } else {
                match.postResultTimeNumber = nil
            }
            match.breakdown = model.breakdown

            match.updateToManyRelationship(relationship: #keyPath(Match.videosMany), newValues: model.videos?.map({
                return MatchVideo.insert($0, in: context)
            }))
        }
    }

    override public func prepareForDeletion() {
        super.prepareForDeletion()

        videos.forEach({
            if $0.matches.onlyObject(self) {
                // Match Video will become an orphan - delete
                managedObjectContext?.delete($0)
            } else {
                $0.removeFromMatchesMany(self)
            }
        })
    }

}

extension Match {

    public static func forKey(_ key: String, in context: NSManagedObjectContext) -> Match? {
        let predicate = Match.predicate(key: key)
        return Match.findOrFetch(in: context, matching: predicate)
    }

    /**
     Start time for the match, actual or a guess. In order
     - Returns actual start time for the match
     - Returns predicted start time for the match
     - Returns scheduled start time for the match
     */
    public var startTime: Int? {
        return actualTime ?? predictedTime ?? time ?? nil
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

        let date = Date(timeIntervalSince1970: TimeInterval(startTime))
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
        return alliances.reduce([], { $0 + ($1.teams.array as? [Team] ?? []) })
    }

    /**
     Returns the team keys that were DQ'd in this match - not specifically any alliance
     */
    public var dqTeamKeys: [String] {
        return (blueAlliance?.dqTeamKeys ?? []) + (redAlliance?.dqTeamKeys ?? [])
    }

    private func alliance(with allianceKey: String) -> MatchAlliance? {
        return alliances.first(where: { $0.allianceKey == allianceKey })
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

extension Match: Orphanable {

    public var isOrphaned: Bool {
        guard let managedObjectContext = managedObjectContext else {
            return true
        }

        // Match is orphaned if it isn't associated with an Event and isn't associated with a myTBA object
        let myTBAPredicate = NSPredicate(format: "%K == %@",
                                         #keyPath(MyTBAEntity.modelKey), key)
        let myTBAObject = MyTBAEntity.findOrFetch(in: managedObjectContext, matching: myTBAPredicate)

        return eventOne == nil && myTBAObject == nil
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
