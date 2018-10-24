import Foundation
import TBAKit
import CoreData

// https://github.com/the-blue-alliance/the-blue-alliance/blob/1324e9e5b7c4ab21315bd00a768112991bada108/models/match.py#L25
public enum MatchCompLevel: String, CaseIterable {
    case qualification = "qm"
    case eightfinal = "ef"
    case quarterfinal = "qf"
    case semifinal = "sf"
    case final = "f"

    var sortOrder: Int {
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
    var level: String {
        switch self {
        case .qualification:
            return "Qualification"
        case .eightfinal:
            return "Octofinal"
        case .quarterfinal:
            return "Quarterfinal"
        case .semifinal:
            return "Semifinal"
        case .final:
            return "Finals"
        }
    }

    // https://github.com/the-blue-alliance/the-blue-alliance/blob/1324e9e5b7c4ab21315bd00a768112991bada108/models/match.py#L27
    /**
     Abbreviated human readable string representing the compLevel for the match.
     */
    var levelShort: String {
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

    /**
     Returns the MatchCompLevel for the Match's compLevelString.
     */
    var compLevel: MatchCompLevel? {
        guard let compLevelString = compLevelString else {
            return nil
        }
        return MatchCompLevel(rawValue: compLevelString)
    }

    /**
     The formatted Match time.
     */
    var timeString: String? {
        guard let time = time else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE h:mm a"

        let date = Date(timeIntervalSince1970: time.doubleValue)
        return dateFormatter.string(from: date)
    }

    /**
     Returns the alliance with an allianceKey of 'red'.
     */
    var redAlliance: MatchAlliance? {
        return alliance(with: "red")
    }

    /**
     Returns the trimmed team keys for the red alliance.
     */
    var redAllianceTeamNumbers: [String] {
        return (redAlliance?.teams?.array as? [TeamKey])?.map({ Team.trimFRCPrefix($0.key!) }).reversed() ?? []
    }

    /**
     Returns the alliance with an allianceKey of 'blue'.
     */
    var blueAlliance: MatchAlliance? {
        return alliance(with: "blue")
    }

    /**
     Returns the trimmed team keys for the blue alliance.
     */
    var blueAllianceTeamNumbers: [String] {
        return (blueAlliance?.teams!.array as? [TeamKey])?.map({ Team.trimFRCPrefix($0.key!) }).reversed() ?? []
    }

    private func alliance(with allianceKey: String) -> MatchAlliance? {
        return (alliances?.allObjects as? [MatchAlliance])?.first(where: { $0.allianceKey == allianceKey })
    }

    var friendlyName: String {
        switch compLevel {
        case .none:
            return "Match \(matchNumber!.stringValue)"
        case .some(let compLevel):
            if compLevel == .qualification {
                return "\(compLevel.levelShort) \(matchNumber!.stringValue)"
            } else {
                return "\(compLevel.levelShort) \(setNumber!.stringValue) - \(matchNumber!.stringValue)"
            }
        }
    }

}

extension Match: Managed {

    @discardableResult
    static func insert(with model: TBAMatch, for event: Event, in context: NSManagedObjectContext) -> Match {
        let predicate = NSPredicate(format: "key == %@", model.key)
        return findOrCreate(in: context, matching: predicate) { (match) in
            // Required: compLevel, eventKey, key, matchNumber, setNumber
            match.key = model.key
            match.compLevelString = model.compLevel

            // When adding a new MatchCompLevel, models will need a migration to update this
            if let compLevel = MatchCompLevel(rawValue: model.compLevel) {
                match.compLevelSortOrder = compLevel.sortOrder as NSNumber
            } else {
                match.compLevelSortOrder = nil
            }

            match.setNumber = model.setNumber as NSNumber
            match.matchNumber = model.matchNumber as NSNumber

            updateToManyRelationship(relationship: &match.alliances, newValues: model.alliances?.map({ (key: String, value: TBAMatchAlliance) -> MatchAlliance in
                return MatchAlliance.insert(with: value, allianceKey: key, for: match, in: context)
            }), matchingOrphans: { _ in
                // Match Alliance will never belong to more than one Match, so this should always be true
                return true
            }, in: context)

            match.winningAlliance = model.winningAlliance
            match.event = event

            match.time = model.time as NSNumber?
            match.actualTime = model.actualTime as NSNumber?
            match.predictedTime = model.predictedTime as NSNumber?
            match.postResultTime = model.postResultTime as NSNumber?
            match.breakdown = model.breakdown

            updateToManyRelationship(relationship: &match.videos, newValues: model.videos?.map({ (modelVideo) -> MatchVideo in
                return MatchVideo.insert(with: modelVideo, in: context)
            }), matchingOrphans: { _ in
                // Match Video will never belong to more than one Match, so this should always be true
                return true
            }, in: context)
        }
    }

    // TODO: Probably a method to insert Match on Event

}