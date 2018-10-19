import Foundation
import TBAKit
import CoreData

public enum MatchCompLevel: String {
    case qualification = "qm"
    case eightfinal = "ef"
    case quarterfinal = "qf"
    case semifinal = "sf"
    case final = "f"

    var intVal: Int16 {
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
}

extension Match: Managed {

    var compLevelString: String {
        guard let compLevel = compLevel else {
            return ""
        }
        switch compLevel {
        case MatchCompLevel.qualification.rawValue:
            return "Qualification"
        case MatchCompLevel.eightfinal.rawValue:
            return "Octofinal"
        case MatchCompLevel.quarterfinal.rawValue:
            return "Quarterfinal"
        case MatchCompLevel.semifinal.rawValue:
            return "Semifinal"
        case MatchCompLevel.final.rawValue:
            return "Finals"
        default:
            return ""
        }
    }

    var shortCompLevelString: String {
        guard let compLevel = compLevel else {
            return ""
        }
        switch compLevel {
        case MatchCompLevel.qualification.rawValue:
            return "Quals"
        case MatchCompLevel.eightfinal.rawValue:
            return "Eighths"
        case MatchCompLevel.quarterfinal.rawValue:
            return "Quarters"
        case MatchCompLevel.semifinal.rawValue:
            return "Semis"
        case MatchCompLevel.final.rawValue:
            return "Finals"
        default:
            return ""
        }
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
            match.compLevel = model.compLevel

            let compLevelStruct = MatchCompLevel(rawValue: match.compLevel!)
            match.compLevelInt = compLevelStruct!.intVal

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
                    return MatchVideo.insert(with: modelVideo, for: match, in: context)
                })) as NSSet
            } else {
                match.videos = nil
            }
        }
    }

    public func friendlyMatchName() -> String {
        guard let compLevel = compLevel else {
            return ""
        }

        let matchName = shortCompLevelString

        switch compLevel {
        case MatchCompLevel.qualification.rawValue:
            return "\(matchName) \(matchNumber)"
        case MatchCompLevel.eightfinal.rawValue,
             MatchCompLevel.quarterfinal.rawValue,
             MatchCompLevel.semifinal.rawValue,
             MatchCompLevel.final.rawValue:
            return "\(matchName) \(setNumber) - \(matchNumber)"

        default:
            return matchName
        }
    }

}
