import Foundation

public struct TBADistrict: TBAModel {
    
    public var abbreviation: String
    public var name: String
    public var key: String
    public var year: Int

    public init(abbreviation: String, name: String, key: String, year: Int) {
        self.abbreviation = abbreviation
        self.name = name
        self.key = key
        self.year = year
    }

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

    public init(teamKey: String, rank: Int, rookieBonus: Int? = nil, pointTotal: Int, eventPoints: [TBADistrictEventPoints]) {
        self.teamKey = teamKey
        self.rank = rank
        self.rookieBonus = rookieBonus
        self.pointTotal = pointTotal
        self.eventPoints = eventPoints
    }

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
            for var result in eventPointsJSON {
                // Add team key to JSON
                result["team_key"] = teamKey

                if let eventPoint = TBADistrictEventPoints(json: result) {
                    eventPoints.append(eventPoint)
                }
            }
        }
        self.eventPoints = eventPoints
    }
    
}

public struct TBADistrictEventPoints: TBAModel, Equatable {

    public var teamKey: String
    public var eventKey: String
    public var districtCMP: Bool?
    public var alliancePoints: Int
    public var awardPoints: Int
    public var qualPoints: Int
    public var elimPoints: Int
    public var total: Int

    public init(teamKey: String, eventKey: String, districtCMP: Bool? = false, alliancePoints: Int, awardPoints: Int, qualPoints: Int, elimPoints: Int, total: Int) {
        self.teamKey = teamKey
        self.eventKey = eventKey
        self.districtCMP = districtCMP
        self.alliancePoints = alliancePoints
        self.awardPoints = awardPoints
        self.qualPoints = qualPoints
        self.elimPoints = elimPoints
        self.total = total
    }

    init?(json: [String: Any]) {
        guard let eventKey = json["event_key"] as? String else {
            return nil
        }
        self.eventKey = eventKey

        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey

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

    public init(teamKey: String, highestQualScores: [Int], qualWins: Int) {
        self.teamKey = teamKey
        self.highestQualScores = highestQualScores
        self.qualWins = qualWins
    }
    
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

    public func fetchDistricts(year: Int, completion: @escaping (Result<[TBADistrict], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "districts/\(year)"
        return callArray(method: method, completion: completion)
    }

    public func fetchDistrictEvents(key: String, completion: @escaping (Result<[TBAEvent], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "district/\(key)/events"
        return callArray(method: method, completion: completion)
    }

    public func fetchDistrictTeams(key: String, completion: @escaping (Result<[TBATeam], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "district/\(key)/teams"
        return callArray(method: method, completion: completion)
    }

    public func fetchDistrictRankings(key: String, completion: @escaping (Result<[TBADistrictRanking], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "district/\(key)/rankings"
        return callArray(method: method, completion: completion)
    }

}
