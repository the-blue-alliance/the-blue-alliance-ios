//
//  Match.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

/*
import Foundation
import TBAUtils

public enum MatchCompLevel: String, Comparable, CaseIterable {
    case qualification = "qm"
    case eightfinal = "ef"
    case quarterfinal = "qf"
    case semifinal = "sf"
    case final = "f"

    fileprivate var sortOrder: Int {
        switch self {
        case .qualification:
            return 1
        case .eightfinal:
            return 2
        case .quarterfinal:
            return 3
        case .semifinal:
            return 4
        case .final:
            return 5
        }
    }
    static let nilSortOrder = MatchCompLevel.allCases.count + 1

    public static func < (lhs: MatchCompLevel, rhs: MatchCompLevel) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }

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

public struct Match: Decodable {
    public var key: MatchKey
    public var compLevelString: String
    public var compLevel: MatchCompLevel? {
        MatchCompLevel(rawValue: compLevelString)
    }
    public var setNumber: Int
    public var matchNumber: Int
    public var alliances: [String: MatchAlliance]?
    public var winningAlliance: String?
    public var eventKey: EventKey
    public var time: Int64?
    public var actualTime: Int64?
    public var predictedTime: Int64?
    public var postResultTime: Int64?
    public var breakdown: [String: Any]?
    public var videos: [MatchVideo]?

    enum CodingKeys: String, CodingKey {
        case key
        case compLevelString = "comp_level"
        case setNumber = "set_number"
        case matchNumber = "match_number"
        case alliances
        case winningAlliance = "winning_alliance"
        case eventKey = "event_key"
        case time
        case actualTime = "actual_time"
        case predictedTime = "predicted_time"
        case postResultTime = "post_result_time"
        case breakdown = "score_breakdown"
        case videos
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decode(String.self, forKey: .key)
        compLevelString = try values.decode(String.self, forKey: .compLevelString)
        setNumber = try values.decode(Int.self, forKey: .setNumber)
        matchNumber = try values.decode(Int.self, forKey: .matchNumber)
        alliances = try values.decodeIfPresent([String: MatchAlliance].self, forKey: .alliances)
        winningAlliance = try values.decodeIfPresent(String.self, forKey: .winningAlliance)
        eventKey = try values.decode(String.self, forKey: .eventKey)
        time = try values.decodeIfPresent(Int64.self, forKey: .time)
        actualTime = try values.decodeIfPresent(Int64.self, forKey: .actualTime)
        predictedTime = try values.decodeIfPresent(Int64.self, forKey: .predictedTime)
        postResultTime = try values.decodeIfPresent(Int64.self, forKey: .postResultTime)
        breakdown = try values.decodeIfPresent([String: Any].self, forKey: .breakdown)
        videos = try values.decodeIfPresent([MatchVideo].self, forKey: .videos)
    }
}

extension Match {
    fileprivate var compLevelOrder: Int {
        return compLevel?.sortOrder ?? MatchCompLevel.nilSortOrder
    }

    public var friendlyName: String {
        guard let compLevel else {
            return "Match \(matchNumber)"
        }
        if compLevel == .qualification {
            return "\(compLevel.levelShort) \(matchNumber)"
        }
        return "\(compLevel.levelShort) \(setNumber)-\(matchNumber)"
    }
}

extension Array where Element == Match {
    public func sorted() -> Array<Element> {
        return sorted(byPlayOrder: false)
    }

    public func sorted(byPlayOrder: Bool = false) -> Array<Element> {
        let compLevelSort = KeyPathComparator(\Match.compLevelOrder)
        let sorts: [KeyPathComparator<Match>] = {
            if byPlayOrder {
                return [
                    KeyPathComparator(\.matchNumber),
                    KeyPathComparator(\.setNumber)
                ]
            }
            return [
                KeyPathComparator(\.setNumber),
                KeyPathComparator(\.matchNumber)
            ]
        }()
        return sorted(using: [compLevelSort] + sorts)
    }
}

public struct MatchVideo: Decodable {
    public var key: String
    public var type: String

    enum CodingKeys: String, CodingKey {
        case key
        case type
    }
}

public struct MatchAlliance: Decodable {
    public var score: Int
    public var teamKeys: [String]
    public var surrogateTeamKeys: [String]?
    public var dqTeamKeys: [String]?

    enum CodingKeys: String, CodingKey {
        case score
        case teamKeys = "team_keys"
        case surrogateTeamKeys = "surrogate_team_keys"
        case dqTeamKeys = "dq_team_keys"
    }
}

public struct MatchZebra: Decodable {
    public var key: String
    public var times: [Double]
    public var alliances: [String: [MachZebraTeam]]

    enum CodingKeys: String, CodingKey {
        case key
        case times
        case alliances
    }
}

public struct MachZebraTeam: Decodable {
    public var teamKey: String
    public var xs: [Double?]
    public var ys: [Double?]

    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case xs
        case ys
    }
}
*/
