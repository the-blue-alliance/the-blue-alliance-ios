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

extension Match: Managed {

    var compLevel: MatchCompLevel? {
        guard let compLevelString = compLevelString else {
            return nil
        }
        return MatchCompLevel(rawValue: compLevelString)
    }

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
        return redAlliance?.teams.map({ Team.trimFRCPrefix($0) }).reversed() ?? []
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
        return blueAlliance?.teams.map({ Team.trimFRCPrefix($0) }).reversed() ?? []
    }

    private func alliance(with allianceKey: String) -> MatchAlliance? {
        return (alliances?.allObjects as? [MatchAlliance])?.first(where: { $0.allianceKey == allianceKey })
    }

    @discardableResult
    static func insert(with model: TBAMatch, for event: Event, in context: NSManagedObjectContext) -> Match {
        let predicate = NSPredicate(format: "key == %@", model.key)
        return findOrCreate(in: context, matching: predicate) { (match) in
            // Required: compLevel, eventKey, key, matchNumber, setNumber
            match.key = model.key
            match.compLevelString = model.compLevel

            // When adding a new MatchCompLevel, models will need a migration to update this
            if let compLevel = MatchCompLevel(rawValue: model.compLevel) {
                match.compLevelSortOrder = Int16(compLevel.sortOrder)
            }

            match.setNumber = Int16(model.setNumber)
            match.matchNumber = Int16(model.matchNumber)

            if let alliances = model.alliances {
                match.alliances = Set(alliances.map({ (key: String, value: TBAMatchAlliance) -> MatchAlliance in
                    return MatchAlliance.insert(with: value, allianceKey: key, for: match, in: context)
                })) as NSSet
            } else {
                match.alliances = nil
            }

            match.winningAlliance = model.winningAlliance
            match.event = event

            if let time = model.time {
                match.time = NSNumber(value: time)
            } else {
                match.time = nil
            }

            if let actualTime = model.actualTime {
                match.actualTime = NSNumber(value: actualTime)
            } else {
                match.actualTime = nil
            }

            if let predictedTime = model.predictedTime {
                match.predictedTime = NSNumber(value: predictedTime)
            } else {
                match.predictedTime = nil
            }

            if let postResultTime = model.postResultTime {
                match.postResultTime = NSNumber(value: postResultTime)
            } else {
                match.postResultTime = nil
            }

            match.breakdown = model.breakdown

            if let videos = model.videos {
                match.videos = Set(videos.map({ (modelVideo) -> MatchVideo in
                    return MatchVideo.insert(with: modelVideo, in: context)
                })) as NSSet
            } else {
                match.videos = nil
            }
        }
    }

    var friendlyName: String {
        switch compLevel {
        case .none:
            return "Match \(matchNumber)"
        case .some(let compLevel):
            if compLevel == .qualification {
                return "\(compLevel.levelShort) \(matchNumber)"
            } else {
                return "\(compLevel.levelShort) \(setNumber) - \(matchNumber)"
            }
        }
    }

}
