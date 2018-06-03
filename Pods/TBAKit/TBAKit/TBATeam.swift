//
//  TBATeam.swift
//  Pods
//
//  Created by Zach Orr on 1/7/17.
//
//

import UIKit

public struct TBATeam: TBAModel {
    public var key: String
    public var teamNumber: Int
    public var nickname: String?
    public var name: String
    public var city: String?
    public var stateProv: String?
    public var country: String?
    public var address: String?
    public var postalCode: String?
    public var gmapsPlaceID: String?
    public var gmapsURL: String?
    public var lat: Double?
    public var lng: Double?
    public var locationName: String?
    public var website: String?
    public var rookieYear: Int
    public var motto: String?
    public var homeChampionship: [String: String]?

    init?(json: [String: Any]) {
        // Required: key, name, teamNumber, rookieYear
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key
        
        guard let name = json["name"] as? String else {
            return nil
        }
        self.name = name
        
        guard let teamNumber = json["team_number"] as? Int else {
            return nil
        }
        self.teamNumber = teamNumber
        
        guard let rookieYear = json["rookie_year"] as? Int else {
            return nil
        }
        self.rookieYear = rookieYear
        
        self.address = json["address"] as? String
        self.city = json["city"] as? String
        self.country = json["country"] as? String
        self.gmapsPlaceID = json["gmaps_place_id"] as? String
        self.gmapsURL = json["gmaps_url"] as? String
        self.homeChampionship = json["home_championship"] as? [String: String]
        self.lat = json["lat"] as? Double
        self.lng = json["lng"] as? Double
        self.locationName = json["location_name"] as? String
        self.motto = json["motto"] as? String
        self.nickname = json["nickname"] as? String
        self.postalCode = json["postal_code"] as? String
        self.stateProv = json["state_prov"] as? String
        self.teamNumber = teamNumber
        self.website = json["website"] as? String
    }

}

public struct TBARobot: TBAModel {
    public var key: String
    public var name: String
    public var teamKey: String
    public var year: Int
    
    init?(json: [String: Any]) {
        // Required: key, name, teamKey, year
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key

        guard let name = json["robot_name"] as? String else {
            return nil
        }
        self.name = name

        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey

        guard let year = json["year"] as? Int else {
            return nil
        }
        self.year = year
    }

}

public struct TBAEventStatus: TBAModel {
    
    public var teamKey: String
    public var eventKey: String
    
    public var qual: TBAEventStatusQual?
    public var alliance: TBAEventStatusAlliance?
    public var playoff: TBAAllianceStatus?
    
    public var allianceStatusString: String?
    public var playoffStatusString: String?
    public var overallStatusString: String?
    
    public var nextMatchKey: String?
    public var lastMatchKey: String?
    
    init?(json: [String: Any]) {
        // Required: teamKey, eventKey (as passed in by JSON manually)
        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey

        guard let eventKey = json["event_key"] as? String else {
            return nil
        }
        self.eventKey = eventKey
        
        if let qualJSON = json["qual"] as? [String: Any] {
            self.qual = TBAEventStatusQual(json: qualJSON)
        }
        
        if let allianceJSON = json["alliance"] as? [String: Any] {
            self.alliance = TBAEventStatusAlliance(json: allianceJSON)
        }
        
        if let playoffJSON = json["playoff"] as? [String: Any] {
            self.playoff = TBAAllianceStatus(json: playoffJSON)
        }

        self.allianceStatusString = json["alliance_status_str"] as? String
        self.playoffStatusString = json["playoff_status_str"] as? String
        self.overallStatusString = json["overall_status_str"] as? String
        self.nextMatchKey = json["next_match_key"] as? String
        self.lastMatchKey = json["last_match_key"] as? String
    }
    
}

public struct TBAEventStatusQual: TBAModel {
    
    public var numTeams: Int?
    public var status: String?
    public var ranking: TBAEventRanking?
    public var sortOrder: [TBAEventRankingSortOrder]?
    
    init?(json: [String: Any]) {
        self.numTeams = json["num_teams"] as? Int
        self.status = json["status"] as? String
        
        if let rankingJSON = json["ranking"] as? [String: Any] {
            self.ranking = TBAEventRanking(json: rankingJSON)
        }
        
        if let sortOrdersJSON = json["sort_order_info"] as? [[String: Any]] {
            self.sortOrder = sortOrdersJSON.compactMap({ (sortOrderJSON) -> TBAEventRankingSortOrder? in
                return TBAEventRankingSortOrder(json: sortOrderJSON)
            })
        }
    }
    
}

public struct TBAEventStatusAlliance: TBAModel {
    
    public var number: Int
    public var pick: Int
    public var name: String?
    public var backup: TBAAllianceBackup?
    
    init?(json: [String: Any]) {
        // Required: number, pick
        guard let number = json["number"] as? Int else {
            return nil
        }
        self.number = number
        
        guard let pick = json["pick"] as? Int else {
            return nil
        }
        self.pick = pick
        
        self.name = json["name"] as? String
        
        if let backupJSON = json["backup"] as? [String: Any] {
            self.backup = TBAAllianceBackup(json: backupJSON)
        }
    }

}

public struct TBAMedia: TBAModel{
    
    public var key: String?
    public var type: String
    public var foreignKey: String?
    public var details: [String: Any]?
    public var preferred: Bool?
    
    init?(json: [String: Any]) {
        // Required: type
        self.key = json["key"] as? String
        
        guard let type = json["type"] as? String else {
            return nil
        }
        self.type = type
        
        self.foreignKey = json["foreign_key"] as? String
        self.details = json["details"] as? [String: Any]
        self.preferred = json["preferred"] as? Bool
    }
    
}

extension TBAKit {

    public func fetchTeams(page: Int, year: Int? = nil, completion: @escaping ([TBATeam]?, Error?) -> ()) -> URLSessionDataTask {
        var method = "teams"
        if let year = year {
            method = "\(method)/\(year)"
        }
        method = "\(method)/\(page)"
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeam(key: String, completion: @escaping (TBATeam?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)"
        return callObject(method: method, completion: completion)
    }
    
    public func fetchTeamYearsParticipated(key: String, completion: @escaping ([Int]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/years_participated"
        return callArray(method: method) { (years, error) in
            if let error = error {
                completion(nil, error)
            } else if let years = years as? [Int]? {
                completion(years, nil)
            } else {
                completion(nil, APIError.error("Unexpected response from server."))
            }
        }
    }

    public func fetchTeamDistricts(key: String, completion: @escaping ([TBADistrict]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/districts"
        return callArray(method: method, completion: completion)
    }

    public func fetchTeamRobots(key: String, completion: @escaping ([TBARobot]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/robots"
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeamEvents(key: String, year: Int? = nil, completion: @escaping ([TBAEvent]?, Error?) -> ()) -> URLSessionDataTask {
        var method = "team/\(key)/events"
        if let year = year {
            method = "\(method)/\(year)"
        }
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeamStatuses(key: String, year: Int, completion: @escaping ([TBAEventStatus]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/events/\(year)/statuses"
        return callDictionary(method: method, completion: { (dictionary, error) in
            if let error = error {
                completion(nil, error)
            } else if let dictionary = dictionary {
                let eventStatuses = dictionary.compactMap({ (eventKey, statusJSON) -> TBAEventStatus? in
                    // Add teamKey/eventKey to statusJSON
                    guard var json = statusJSON as? [String: Any] else {
                        return nil
                    }
                    json["team_key"] = key
                    json["event_key"] = eventKey

                    return TBAEventStatus(json: json)
                })
                completion(eventStatuses, nil)
            } else {
                completion(nil, APIError.error("Unexpected response from server."))
            }
        })
    }
    
    public func fetchTeamMatches(key: String, eventKey: String, completion: @escaping ([TBAMatch]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/event/\(eventKey)/matches"
        return callArray(method: method, completion: completion)
    }

    public func fetchTeamAwards(key: String, eventKey: String, completion: @escaping ([TBAAward]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/event/\(eventKey)/awards"
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeamStatus(key: String, eventKey: String, completion: @escaping (TBAEventStatus?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/event/\(eventKey)/status"
        return callDictionary(method: method, completion: { (dictionary, error) in
            if let error = error {
                completion(nil, error)
            } else if var dictionary = dictionary {
                dictionary["team_key"] = key
                dictionary["event_key"] = eventKey
                
                if let status = TBAEventStatus(json: dictionary) {
                    completion(status, nil)
                } else {
                    completion(nil, APIError.error("Unexpected response from server."))
                }
            } else {
                completion(nil, APIError.error("Unexpected response from server."))
            }
        })
    }
    
    public func fetchTeamAwards(key: String, year: Int? = nil, completion: @escaping ([TBAAward]?, Error?) -> ()) -> URLSessionDataTask {
        var method = "team/\(key)/awards"
        if let year = year {
            method = "\(method)/\(year)"
        }
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeamMatches(key: String, year: Int, completion: @escaping ([TBAMatch]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/matches/\(year)"
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeamMedia(key: String, year: Int, completion: @escaping ([TBAMedia]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/media/\(year)"
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeamSocialMedia(key: String, completion: @escaping ([TBAMedia]?, Error?) -> ()) -> URLSessionDataTask {
        let method = "team/\(key)/social_media"
        return callArray(method: method, completion: completion)
    }

}
