import Foundation

public struct TBATeam: TBAModel {
    public var key: String
    public var teamNumber: Int
    public var nickname: String?
    public var name: String
    public var schoolName: String?
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
    public var rookieYear: Int?
    public var homeChampionship: [String: String]?

    public init(key: String, teamNumber: Int, nickname: String? = nil, name: String, schoolName: String? = nil, city: String? = nil, stateProv: String? = nil, country: String? = nil, address: String? = nil, postalCode: String? = nil, gmapsPlaceID: String? = nil, gmapsURL: String? = nil, lat: Double? = nil, lng: Double? = nil, locationName: String? = nil, website: String? = nil, rookieYear: Int? = nil, homeChampionship: [String: String]? = nil) {
        self.key = key
        self.teamNumber = teamNumber
        self.nickname = nickname
        self.name = name
        self.schoolName = schoolName
        self.city = city
        self.stateProv = stateProv
        self.country = country
        self.address = address
        self.postalCode = postalCode
        self.gmapsPlaceID = gmapsPlaceID
        self.gmapsURL = gmapsURL
        self.lat = lat
        self.lng = lng
        self.locationName = locationName
        self.website = website
        self.rookieYear = rookieYear
        self.homeChampionship = homeChampionship
    }

    init?(json: [String: Any]) {
        // Required: key, name, teamNumber
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

        self.address = json["address"] as? String
        self.city = json["city"] as? String
        self.country = json["country"] as? String
        self.gmapsPlaceID = json["gmaps_place_id"] as? String
        self.gmapsURL = json["gmaps_url"] as? String
        self.homeChampionship = json["home_championship"] as? [String: String]
        self.lat = json["lat"] as? Double
        self.lng = json["lng"] as? Double
        self.locationName = json["location_name"] as? String
        self.nickname = json["nickname"] as? String
        self.postalCode = json["postal_code"] as? String
        self.rookieYear = json["rookie_year"] as? Int
        self.schoolName = json["school_name"] as? String
        self.stateProv = json["state_prov"] as? String
        self.website = json["website"] as? String
    }

}

public struct TBARobot: TBAModel {
    public var key: String
    public var name: String
    public var teamKey: String
    public var year: Int

    public init(key: String, name: String, teamKey: String, year: Int) {
        self.key = key
        self.name = name
        self.teamKey = teamKey
        self.year = year
    }

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

    public init(teamKey: String, eventKey: String, qual: TBAEventStatusQual? = nil, alliance: TBAEventStatusAlliance? = nil, playoff: TBAAllianceStatus? = nil, allianceStatusString: String? = nil, playoffStatusString: String? = nil, overallStatusString: String? = nil, nextMatchKey: String? = nil, lastMatchKey: String? = nil) {
        self.teamKey = teamKey
        self.eventKey = eventKey

        self.qual = qual
        self.alliance = alliance
        self.playoff = playoff

        self.allianceStatusString = allianceStatusString
        self.playoffStatusString = playoffStatusString
        self.overallStatusString = overallStatusString

        self.nextMatchKey = nextMatchKey
        self.lastMatchKey = lastMatchKey
    }

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

    public init(numTeams: Int? = nil, status: String? = nil, ranking: TBAEventRanking? = nil, sortOrder: [TBAEventRankingSortOrder]? = nil) {
        self.numTeams = numTeams
        self.status = status
        self.ranking = ranking
        self.sortOrder = sortOrder
    }

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

    public init(number: Int, pick: Int, name: String? = nil, backup: TBAAllianceBackup? = nil) {
        self.number = number
        self.pick = pick
        self.name = name
        self.backup = backup
    }

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

public struct TBAMedia: TBAModel {

    public var type: String
    public var foreignKey: String
    public var details: [String: Any]?
    public var preferred: Bool
    public var directURL: String?
    public var viewURL: String?

    public init(type: String, foreignKey: String, details: [String: Any]? = nil, preferred: Bool = false, directURL: String? = nil, viewURL: String? = nil) {
        self.type = type
        self.foreignKey = foreignKey
        self.details = details
        self.preferred = preferred
        self.directURL = directURL
        self.viewURL = viewURL
    }

    init?(json: [String: Any]) {
        // Required: type, foreign_key
        guard let type = json["type"] as? String else {
            return nil
        }
        self.type = type

        guard let foreignKey = json["foreign_key"] as? String else {
            return nil
        }
        self.foreignKey = foreignKey

        self.details = json["details"] as? [String: Any]
        self.preferred = json["preferred"] as? Bool ?? false
        self.directURL = json["direct_url"] as? String
        self.viewURL = json["view_url"] as? String
    }

}

extension TBAKit {

    public func fetchTeams(simple: Bool = false, completion: @escaping (Result<[TBATeam], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = simple ? "teams/all/simple" : "teams/all"
        return callArray(method: method, completion: completion)
    }

    public func fetchTeams(page: Int, year: Int? = nil, completion: @escaping (Result<[TBATeam], Error>, Bool) -> ()) -> TBAKitOperation {
        var method = "teams"
        if let year = year {
            method = "\(method)/\(year)"
        }
        method = "\(method)/\(page)"
        return callArray(method: method, completion: completion)
    }

    public func fetchTeam(key: String, completion: @escaping (Result<TBATeam?, Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)"
        return callObject(method: method, completion: completion)
    }

    public func fetchTeamYearsParticipated(key: String, completion: @escaping (Result<[Int], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/years_participated"
        return callArray(method: method) { (result, notModified) in
            switch result {
            case .failure(let error):
                completion(.failure(error), notModified)
            case .success(let years):
                if let years = years as? [Int] {
                    completion(.success(years), notModified)
                } else {
                    completion(.failure(APIError.error("Unexpected response from server.")), notModified)
                }
            }
        }
    }

    public func fetchTeamDistricts(key: String, completion: @escaping (Result<[TBADistrict], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/districts"
        return callArray(method: method, completion: completion)
    }

    public func fetchTeamRobots(key: String, completion: @escaping (Result<[TBARobot], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/robots"
        return callArray(method: method, completion: completion)
    }

    public func fetchTeamEvents(key: String, year: Int? = nil, completion: @escaping (Result<[TBAEvent], Error>, Bool) -> ()) -> TBAKitOperation {
        var method = "team/\(key)/events"
        if let year = year {
            method = "\(method)/\(year)"
        }
        return callArray(method: method, completion: completion)
    }

    public func fetchTeamStatuses(key: String, year: Int, completion: @escaping (Result<[TBAEventStatus], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/events/\(year)/statuses"
        return callDictionary(method: method, completion: { (result, notModified) in
            switch result {
            case .failure(let error):
                completion(.failure(error), notModified)
            case .success(let dictionary):
                let eventStatuses = dictionary.compactMap({ (eventKey, statusJSON) -> TBAEventStatus? in
                    // Add teamKey/eventKey to statusJSON
                    guard var json = statusJSON as? [String: Any] else {
                        return nil
                    }
                    json["team_key"] = key
                    json["event_key"] = eventKey

                    return TBAEventStatus(json: json)
                })
                completion(.success(eventStatuses), notModified)
            }
        })
    }

    public func fetchTeamMatches(key: String, eventKey: String, completion: @escaping (Result<[TBAMatch], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/event/\(eventKey)/matches"
        return callArray(method: method, completion: completion)
    }

    public func fetchTeamAwards(key: String, eventKey: String, completion: @escaping (Result<[TBAAward], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/event/\(eventKey)/awards"
        return callArray(method: method, completion: completion)
    }

    public func fetchTeamStatus(key: String, eventKey: String, completion: @escaping (Result<TBAEventStatus?, Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/event/\(eventKey)/status"
        return callDictionary(method: method, completion: { (result, notModified) in
            switch result {
            case .failure(let error):
                completion(.failure(error), notModified)
            case .success(var dictionary):
                dictionary["team_key"] = key
                dictionary["event_key"] = eventKey

                if let status = TBAEventStatus(json: dictionary) {
                    completion(.success(status), notModified)
                } else {
                    completion(.failure(APIError.error("Unexpected response from server.")), notModified)
                }
            }
        })
    }
    
    public func fetchTeamAwards(key: String, year: Int? = nil, completion: @escaping (Result<[TBAAward], Error>, Bool) -> ()) -> TBAKitOperation {
        var method = "team/\(key)/awards"
        if let year = year {
            method = "\(method)/\(year)"
        }
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeamMatches(key: String, year: Int, completion: @escaping (Result<[TBAMatch], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/matches/\(year)"
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeamMedia(key: String, year: Int, completion: @escaping (Result<[TBAMedia], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/media/\(year)"
        return callArray(method: method, completion: completion)
    }
    
    public func fetchTeamSocialMedia(key: String, completion: @escaping (Result<[TBAMedia], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "team/\(key)/social_media"
        return callArray(method: method, completion: completion)
    }

}
