//
//  TBADistrict.swift
//  Pods
//
//  Created by Zach Orr on 3/13/17.
//
//

import Foundation

public struct TBADistrict: TBAModel {
    
    public var abbreviation: String
    public var name: String
    public var key: String
    public var year: Int
    
    init?(json: [String: Any]) {
        // Required: abbreviation, key, name, year
        guard let abbreviation = json["abbreviation"] as? String else {
            return nil
        }
        self.abbreviation = abbreviation

        guard let name = json["display_name"] as? String else {
            return nil
        }
        self.name = name

        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key

        guard let year = json["year"] as? Int else {
            return nil
        }
        self.year = year
    }
    
}

public struct TBADistrictRanking: TBAModel {
    
    public var teamKey: String
    public var rank: Int
    public var rookieBonus: Int?
    public var pointTotal: Int
    public var eventPoints: [TBADistrictEventPoints]
    
    init?(json: [String: Any]) {
        // Required: teamKey, pointTotal, rank, eventPoints
        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey
        
        guard let rank = json["rank"] as? Int else {
            return nil
        }
        self.rank = rank
        
        self.rookieBonus = json["rookie_bonus"] as? Int
        
        guard let pointTotal = json["point_total"] as? Int else {
            return nil
        }
        self.pointTotal = pointTotal
        
        var eventPoints: [TBADistrictEventPoints] = []
        if let eventPointsJSON = json["event_points"] as? [[String: Any]] {
            for result in eventPointsJSON {
                if let eventPoint = TBADistrictEventPoints(json: result) {
                    eventPoints.append(eventPoint)
                }
            }
        }
        self.eventPoints = eventPoints
    }
    
}

public struct TBADistrictEventPoints: TBAModel {

    // teamKey will exist when fetching rankings for an event
    // eventKey exist when fething rankings for a district
    public var teamKey: String?
    public var eventKey: String?
    public var districtCMP: Bool?
    public var alliancePoints: Int
    public var awardPoints: Int
    public var qualPoints: Int
    public var elimPoints: Int
    public var total: Int
    
    init?(json: [String: Any]) {
        if let eventKey = json["event_key"] as? String {
            self.eventKey = eventKey
        }
        
        if let teamKey = json["team_key"] as? String {
            self.teamKey = teamKey
        }
        
        if let districtCMP = json["district_cmp"] as? Bool {
            self.districtCMP = districtCMP
        }
        
        let alliancePoints = json["alliance_points"] as? Int ?? 0
        self.alliancePoints = alliancePoints
        
        let awardPoints = json["award_points"] as? Int ?? 0
        self.awardPoints = awardPoints
        
        let qualPoints = json["qual_points"] as? Int ?? 0
        self.qualPoints = qualPoints
        
        let elimPoints = json["elim_points"] as? Int ?? 0
        self.elimPoints = elimPoints
        
        self.total = json["total"] as? Int ?? (alliancePoints + awardPoints + qualPoints + elimPoints)
    }
    
}

public struct TBADistrictPointsTiebreaker: TBAModel {
    
    public var teamKey: String
    public var highestQualScores: [Int]
    public var qualWins: Int
    
    init?(json: [String: Any]) {
        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey
        
        guard let highestQualScores = json["highest_qual_scores"] as? [Int] else {
            return nil
        }
        self.highestQualScores = highestQualScores
        
        guard let qualWins = json["qual_wins"] as? Int else {
            return nil
        }
        self.qualWins = qualWins
    }
    
}

extension TBAKit {
    
    public func fetchDistricts(year: Int, completion: @escaping ([TBADistrict]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "districts/\(year)"
        return callArray(method: method, completion: completion)
    }
    
    public func fetchDistrictEvents(key: String, completion: @escaping ([TBAEvent]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "district/\(key)/events"
        return callArray(method: method, completion: completion)
    }
    
    public func fetchDistrictTeams(key: String, completion: @escaping ([TBATeam]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "district/\(key)/teams"
        return callArray(method: method, completion: completion)
    }

    public func fetchDistrictRankings(key: String, completion: @escaping ([TBADistrictRanking]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "district/\(key)/rankings"
        return callArray(method: method, completion: completion)
    }

}
