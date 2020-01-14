import Foundation

public struct TBAMatch: TBAModel {

    public var key: String
    public var compLevel: String
    public var setNumber: Int
    public var matchNumber: Int
    public var alliances: [String: TBAMatchAlliance]?
    public var winningAlliance: String?
    public var eventKey: String
    public var time: Int64?
    public var actualTime: Int64?
    public var predictedTime: Int64?
    public var postResultTime: Int64?
    public var breakdown: [String: Any]?
    public var videos: [TBAMatchVideo]?

    public init(key: String, compLevel: String, setNumber: Int, matchNumber: Int, alliances: [String: TBAMatchAlliance]? = nil, winningAlliance: String? = nil, eventKey: String, time: Int64? = nil, actualTime: Int64? = nil, predictedTime: Int64? = nil, postResultTime: Int64? = nil, breakdown: [String: Any]? = nil, videos: [TBAMatchVideo]? = nil) {
        self.key = key
        self.compLevel = compLevel
        self.setNumber = setNumber
        self.matchNumber = matchNumber
        self.alliances = alliances
        self.winningAlliance = winningAlliance
        self.eventKey = eventKey
        self.time = time
        self.actualTime = actualTime
        self.predictedTime = predictedTime
        self.postResultTime = postResultTime
        self.breakdown = breakdown
        self.videos = videos
    }

    init?(json: [String: Any]) {
        // Required: compLevel, eventKey, key, matchNumber, setNumber
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key
        
        guard let compLevel = json["comp_level"] as? String else {
            return nil
        }
        self.compLevel = compLevel

        guard let setNumber = json["set_number"] as? Int else {
            return nil
        }
        self.setNumber = setNumber
        
        guard let matchNumber = json["match_number"] as? Int else {
            return nil
        }
        self.matchNumber = matchNumber

        if let alliancesJSON = json["alliances"] as? [String: [String: Any]] {
            self.alliances = alliancesJSON.compactMapValues({ TBAMatchAlliance(json: $0) })
        }

        self.winningAlliance = json["winning_alliance"] as? String
        
        guard let eventKey = json["event_key"] as? String else {
            return nil
        }
        self.eventKey = eventKey
        
        self.time = json["time"] as? Int64
        self.actualTime = json["actual_time"] as? Int64
        self.predictedTime = json["predicted_time"] as? Int64
        self.postResultTime = json["post_result_time"] as? Int64

        if let breakdown = json["score_breakdown"] as? [String: Any] {
            self.breakdown = breakdown
        }
 
        var videos: [TBAMatchVideo] = []
        if let videoJSON = json["videos"] as? [[String: Any]] {
            for result in videoJSON {
                if let video = TBAMatchVideo(json: result) {
                    videos.append(video)
                }
            }
        }
        self.videos = !videos.isEmpty ? videos : nil
    }
}

public struct TBAMatchVideo: TBAModel {

    public var key: String
    public var type: String

    public init(key: String, type: String) {
        self.key = key
        self.type = type
    }

    init?(json: [String: Any]) {
        // Required: key, type
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key

        guard let type = json["type"] as? String else {
            return nil
        }
        self.type = type
    }
}

public struct TBAMatchAlliance: TBAModel {
    
    public var score: Int
    public var teams: [String]
    public var surrogateTeams: [String]?
    public var dqTeams: [String]?

    public init(score: Int, teams: [String], surrogateTeams: [String]? = nil, dqTeams: [String]? = nil) {
        self.score = score
        self.teams = teams
        self.surrogateTeams = surrogateTeams
        self.dqTeams = dqTeams
    }

    init?(json: [String: Any]) {
        // Required: score, teams
        guard let score = json["score"] as? Int else {
            return nil
        }
        self.score = score
        
        if let surrogateTeamKeys = json["surrogate_team_keys"] as? [String] {
            self.surrogateTeams = surrogateTeamKeys
        }
        
        if let dqTeamKeys = json["dq_team_keys"] as? [String] {
            self.dqTeams = dqTeamKeys
        }
        
        guard let teams = json["team_keys"] as? [String] else {
            return nil
        }
        self.teams = teams
    }
    
}

public struct TBAMatchZebra: TBAModel {
    public var key: String
    public var times: [Double]
    public var alliances: [String: [TBAMachZebraTeam]]

    public init(key: String, times: [Double], alliances: [String: [TBAMachZebraTeam]]) {
        self.key = key
        self.times = times
        self.alliances = alliances
    }

    init?(json: [String: Any]) {
        // Required: key, times, alliances
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key

        guard let times = json["times"] as? [Double] else {
            return nil
        }
        self.times = times

        guard let alliancesJSON = json["alliances"] as? [String: [[String: Any]]] else {
            return nil
        }
        self.alliances = alliancesJSON.compactMapValues({ $0.compactMap({ TBAMachZebraTeam(json: $0) }) })
    }

}

public struct TBAMachZebraTeam: TBAModel {
    public var teamKey: String
    public var xs: [Double?]
    public var ys: [Double?]

    public init(teamKey: String, xs: [Double?], ys: [Double?]) {
        self.teamKey = teamKey
        self.xs = xs
        self.ys = ys
    }

    init?(json: [String : Any]) {
        // Required: teamKey, xs, xy
        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey

        guard let xs = json["xs"] as? [Double?] else {
            return nil
        }
        self.xs = xs

        guard let ys = json["ys"] as? [Double?] else {
            return nil
        }
        self.ys = ys
    }

}

extension TBAKit {

    public func fetchMatch(key: String, _ completion: @escaping (Result<TBAMatch?, Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "match/\(key)"
        return callObject(method: method, completion: completion)
    }

    public func fetchMatchZebra(key: String, _ completion: @escaping (Result<TBAMatchZebra?, Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "match/\(key)/zebra_motionworks"
        return callObject(method: method, completion: completion)
    }

}
