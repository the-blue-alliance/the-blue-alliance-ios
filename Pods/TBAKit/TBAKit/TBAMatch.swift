//
//  TBAMatch.swift
//  Pods
//
//  Created by Zach Orr on 1/15/17.
//
//

import Foundation

public struct TBAMatch: TBAModel {

    public var key: String
    public var compLevel: String
    public var setNumber: Int
    public var matchNumber: Int
    public var redAlliance: TBAMatchAlliance?
    public var blueAlliance: TBAMatchAlliance?
    public var winningAlliance: String?
    public var eventKey: String
    public var time: Int64?
    public var actualTime: Int64?
    public var predictedTime: Int64?
    public var postResultTime: Int64?
    public var redBreakdown: [String: Any]?
    public var blueBreakdown: [String: Any]?
    public var videos: [TBAMatchVideo]?
    
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
            if let redAllianceJSON = alliancesJSON["red"] {
                redAlliance = TBAMatchAlliance(json: redAllianceJSON)
            }
            if let blueAllianceJSON = alliancesJSON["blue"] {
                blueAlliance = TBAMatchAlliance(json: blueAllianceJSON)
            }
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
            if let blueBreakdown = breakdown["blue"] as? [String: Any] {
                self.blueBreakdown = blueBreakdown
            }
            if let redBreakdown = breakdown["red"] as? [String: Any] {
                self.redBreakdown = redBreakdown
            }
            
            // Add coopertition and coopertition points to breakdown in 2015
            if let coopertition = breakdown["coopertition"] as? String {
                self.blueBreakdown?["coopertition"] = coopertition
                self.redBreakdown?["coopertition"] = coopertition
            }
            if let coopertitionPoints = breakdown["coopertition_points"] as? Int {
                self.blueBreakdown?["coopertition_points"] = coopertitionPoints
                self.redBreakdown?["coopertition_points"] = coopertitionPoints
            }
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

extension TBAKit {
    
    public func fetchMatch(key: String, _ completion: @escaping (TBAMatch?, Error?) -> ()) -> URLSessionDataTask {
        let method = "match/\(key)"
        return callObject(method: method, completion: completion)
    }

    public func fetchMatchTimeseries(key: String, completion: @escaping ([[String: Any]]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "match/\(key)/timeseries"
        return callArray(method: method) { (timeseries, error) in
            if let error = error {
                completion(nil, error)
            } else if let timeseries = timeseries as? [[String: Any]]? {
                completion(timeseries, nil)
            } else {
                completion(nil, APIError.error("Unexpected response from server."))
            }
        }
    }

}
