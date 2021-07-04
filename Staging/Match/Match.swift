import CoreData
import Foundation
import MyTBAKit
import TBAKit
import TBAUtils

// https://github.com/the-blue-alliance/the-blue-alliance/blob/
// 1324e9e5b7c4ab21315bd00a768112991bada108/models/match.py#L25
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

    // https://github.com/the-blue-alliance/the-blue-alliance/blob/
    // 1324e9e5b7c4ab21315bd00a768112991bada108/models/match.py#L34
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

    // https://github.com/the-blue-alliance/the-blue-alliance/blob/
    // 1324e9e5b7c4ab21315bd00a768112991bada108/models/match.py#L27
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

    public var actualTime: Int? {
        return getValue(\Match.actualTimeRaw)?.intValue
    }

    public var breakdown: [String: Any]? {
        return getValue(\Match.breakdownRaw)
    }

    public var compLevelSortOrder: Int? {
        return getValue(\Match.compLevelSortOrderRaw)?.intValue
    }

    public var compLevelString: String {
        guard let compLevelString = getValue(\Match.compLevelStringRaw) else {
            fatalError("Save Match before accessing compLevelString")
        }
        return compLevelString
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

    public var key: String {
        guard let key = getValue(\Match.keyRaw) else {
            fatalError("Save Match before accessing key")
        }
        return key
    }

    public var matchNumber: Int {
        guard let matchNumber = getValue(\Match.matchNumberRaw)?.intValue else {
            fatalError("Save Match before accessing matchNumber")
        }
        return matchNumber
    }

    public var postResultTime: Int? {
        return getValue(\Match.postResultTimeRaw)?.intValue
    }

    public var predictedTime: Int? {
        return getValue(\Match.predictedTimeRaw)?.intValue
    }

    public var setNumber: Int {
        guard let setNumber = getValue(\Match.setNumberRaw)?.intValue else {
            fatalError("Save Match before accessing setNumber")
        }
        return setNumber
    }

    public var time: Int? {
        return getValue(\Match.timeRaw)?.intValue
    }

    public var winningAlliance: String? {
        return getValue(\Match.winningAllianceRaw)
    }

    public var alliances: [MatchAlliance] {
        guard let alliancesRaw = getValue(\Match.alliancesRaw),
            let alliances = alliancesRaw.allObjects as? [MatchAlliance] else {
                return []
        }
        return alliances
    }

    public var event: Event {
        guard let event = getValue(\Match.eventRaw) else {
            fatalError("Save Match before accessing event")
        }
        return event
    }

    public var videos: [MatchVideo] {
        guard let videosRaw = getValue(\Match.videosRaw),
            let videos = videosRaw.allObjects as? [MatchVideo] else {
                return []
        }
        return videos
    }

    public var zebra: MatchZebra? {
        return getValue(\Match.zebraRaw)
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

@objc(Match)
public class Match: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Match> {
        return NSFetchRequest<Match>(entityName: Match.entityName)
    }

    @NSManaged var actualTimeRaw: NSNumber?
    @NSManaged var breakdownRaw: [String: Any]?
    @NSManaged var compLevelSortOrderRaw: NSNumber?
    @NSManaged var compLevelStringRaw: String?
    @NSManaged var keyRaw: String?
    @NSManaged var matchNumberRaw: NSNumber?
    @NSManaged var postResultTimeRaw: NSNumber?
    @NSManaged var predictedTimeRaw: NSNumber?
    @NSManaged var setNumberRaw: NSNumber?
    @NSManaged var timeRaw: NSNumber?
    @NSManaged var winningAllianceRaw: String?
    @NSManaged var alliancesRaw: NSSet?
    @NSManaged var eventRaw: Event?
    @NSManaged var videosRaw: NSSet?
    @NSManaged var zebraRaw: MatchZebra?

}

// MARK: Generated accessors for alliancesRaw
extension Match {

    @objc(addAlliancesRawObject:)
    @NSManaged func addToAlliancesRaw(_ value: MatchAlliance)

    @objc(removeAlliancesRawObject:)
    @NSManaged func removeFromAlliancesRaw(_ value: MatchAlliance)

    @objc(addAlliancesRaw:)
    @NSManaged func addToAlliancesRaw(_ values: NSSet)

    @objc(removeAlliancesRaw:)
    @NSManaged func removeFromAlliancesRaw(_ values: NSSet)

}

// MARK: Generated accessors for videosRaw
extension Match {

    @objc(addVideosRawObject:)
    @NSManaged func addToVideosRaw(_ value: MatchVideo)

    @objc(removeVideosRawObject:)
    @NSManaged func removeFromVideosRaw(_ value: MatchVideo)

    @objc(addVideosRaw:)
    @NSManaged func addToVideosRaw(_ values: NSSet)

    @objc(removeVideosRaw:)
    @NSManaged func removeFromVideosRaw(_ values: NSSet)

}

extension Match: Managed {

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Match.keyRaw), key)
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
            match.keyRaw = model.key
            match.compLevelStringRaw = model.compLevel

            // When adding a new MatchCompLevel, models will need a migration to update this
            if let compLevel = MatchCompLevel(rawValue: model.compLevel) {
                match.compLevelSortOrderRaw = NSNumber(value: compLevel.sortOrder)
            } else {
                match.compLevelSortOrderRaw = nil
            }

            match.eventRaw = Event.insert(model.eventKey, in: context)
            match.setNumberRaw = NSNumber(value: model.setNumber)
            match.matchNumberRaw = NSNumber(value: model.matchNumber)

            match.updateToManyRelationship(relationship: #keyPath(Match.alliancesRaw), newValues: model.alliances?.map({ (key: String, value: TBAMatchAlliance) -> MatchAlliance in
                return MatchAlliance.insert(value, allianceKey: key, matchKey: model.key, in: context)
            }))

            match.winningAllianceRaw = model.winningAlliance

            if let time = model.time {
                match.timeRaw = NSNumber(value: time)
            } else {
                match.timeRaw = nil
            }
            if let actualTime = model.actualTime {
                match.actualTimeRaw = NSNumber(value: actualTime)
            } else {
                match.actualTimeRaw = nil
            }
            if let predictedTime = model.predictedTime {
                match.predictedTimeRaw = NSNumber(value: predictedTime)
            } else {
                match.predictedTimeRaw = nil
            }
            if let postResultTime = model.postResultTime {
                match.postResultTimeRaw = NSNumber(value: postResultTime)
            } else {
                match.postResultTimeRaw = nil
            }
            match.breakdownRaw = model.breakdown

            match.updateToManyRelationship(relationship: #keyPath(Match.videosRaw), newValues: model.videos?.map({
                return MatchVideo.insert($0, in: context)
            }))
        }
    }

    /**
     Insert a MatchZebra with values from TBAKit Match Zebra model in to the managed object context.

     This method will manage setting up an MatchZebra's relationship to a Match.

     - Parameter zebra: The TBAKit Match Zebra representations to set values from.
     */
    public func insert(_ zebra: TBAMatchZebra) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToOneRelationship(relationship: #keyPath(Match.zebraRaw), newValue: zebra) {
            return MatchZebra.insert($0, in: managedObjectContext)
        }
    }

    override public func prepareForDeletion() {
        super.prepareForDeletion()

        videos.forEach({
            if $0.matches.onlyObject(self) {
                // Match Video will become an orphan - delete
                managedObjectContext?.delete($0)
            } else {
                $0.removeFromMatchesRaw(self)
            }
        })
    }

}

extension Match {

    public static func compLevelSortOrderKeyPath() -> String {
        return #keyPath(Match.compLevelSortOrderRaw)
    }

    public static func sortDescriptors(ascending: Bool) -> [NSSortDescriptor] {
        // TODO: Support play-by order during event
        return [
            NSSortDescriptor(key: #keyPath(Match.compLevelSortOrderRaw), ascending: ascending),
            NSSortDescriptor(key: #keyPath(Match.setNumberRaw), ascending: ascending),
            NSSortDescriptor(key: #keyPath(Match.matchNumberRaw), ascending: ascending)
        ]
    }

    public static func eventPredicate(eventKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Match.eventRaw.keyRaw), eventKey)
    }

    public static func eventTeamPredicate(eventKey: String, teamKey: String) -> NSPredicate {
        let eventPredicate = Match.eventPredicate(eventKey: eventKey)
        let teamPredicate = Match.teamKeysPredicate(teamKeys: [teamKey])
        return NSCompoundPredicate(andPredicateWithSubpredicates: [eventPredicate, teamPredicate])
    }

    public static func teamKeysPredicate(teamKeys: [String]) -> NSPredicate {
        return NSPredicate(format: "SUBQUERY(%K, $a, ANY $a.%K.%K IN %@).@count > 0",
                           #keyPath(Match.alliancesRaw),
                           #keyPath(MatchAlliance.teamsRaw), #keyPath(Team.keyRaw), teamKeys)
    }

    public static func forKey(_ key: String, in context: NSManagedObjectContext) -> Match? {
        let predicate = Match.predicate(key: key)
        return Match.findOrFetch(in: context, matching: predicate)
    }

}

extension Match: Orphanable {

    public var isOrphaned: Bool {
        guard let managedObjectContext = managedObjectContext else {
            return true
        }

        // Match is orphaned if it isn't associated with an Event and isn't associated with a myTBA object
        let myTBAPredicate = MyTBAEntity.modelKeyPredicate(key: key)
        let myTBAObject = MyTBAEntity.findOrFetch(in: managedObjectContext, matching: myTBAPredicate)

        return eventRaw == nil && myTBAObject == nil
    }

}

extension Match: Comparable {

    public static func <(lhs: Match, rhs: Match) -> Bool {
        if lhs.event.key != rhs.event.key {
            return lhs.event < rhs.event
        }
        if let lhsSortOrder = lhs.compLevelSortOrder, let rhsSortOrder = rhs.compLevelSortOrder {
            return lhsSortOrder < rhsSortOrder
        }
        if lhs.setNumber != rhs.setNumber {
            return lhs.setNumber < rhs.setNumber
        }
        if lhs.matchNumber != rhs.matchNumber {
            return rhs.matchNumber < rhs.matchNumber
        }
        return false
    }

}

extension Match: MyTBASubscribable {

    public var modelKey: String {
        return key
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
