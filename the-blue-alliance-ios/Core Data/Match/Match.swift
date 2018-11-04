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

    /**
     Insert a Match with values from a TBAKit Match model in to the managed object context.

     This method will manage setting up a Match's relationship to an Event and the deletion of oprhaned Match Alliances and Match Videos on a Match.

     - Parameter model: The TBAKit Match representation to set values from.

     - Parameter event: The Event the Matches belong to.

     - Parameter context: The NSManagedContext to insert the Match in to.

     - Returns: The inserted Match.
     */
    @discardableResult
    static func insert(_ model: TBAMatch, event: Event, in context: NSManagedObjectContext) -> Match {
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(Match.key), model.key)

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

            match.updateToManyRelationship(relationship: #keyPath(Match.alliances), newValues: model.alliances?.map({ (key: String, value: TBAMatchAlliance) -> MatchAlliance in
                return MatchAlliance.insert(value, allianceKey: key, matchKey: model.key, in: context)
            }))

            match.winningAlliance = model.winningAlliance
            // This is safe to be used alone, since we take care of the Event <-> Match relationship
            match.event = event

            match.time = model.time as NSNumber?
            match.actualTime = model.actualTime as NSNumber?
            match.predictedTime = model.predictedTime as NSNumber?
            match.postResultTime = model.postResultTime as NSNumber?
            match.breakdown = model.breakdown

            match.updateToManyRelationship(relationship: #keyPath(Match.videos), newValues: model.videos?.map({
                return MatchVideo.insert($0, in: context)
            }))
        }
    }

    var isOrphaned: Bool {
        return event == nil
    }

    override public func prepareForDeletion() {
        super.prepareForDeletion()

        (videos?.allObjects as? [MatchVideo])?.forEach({
            if $0.matches!.onlyObject(self) {
                // Match Video will become an orphan - delete
                managedObjectContext?.delete($0)
            } else {
                $0.removeFromMatches(self)
            }
        })
    }

}
