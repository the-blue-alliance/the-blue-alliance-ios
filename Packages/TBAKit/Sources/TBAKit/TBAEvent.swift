import Foundation

public struct TBAEvent: TBAModel {

    public var key: String
    public var name: String
    public var eventCode: String
    public var eventType: Int
    public var district: TBADistrict?
    public var city: String?
    public var stateProv: String?
    public var country: String?
    public var startDate: Date
    public var endDate: Date
    public var year: Int
    public var shortName: String?
    public var eventTypeString: String
    public var week: Int?
    public var address: String?
    public var postalCode: String?
    public var gmapsPlaceID: String?
    public var gmapsURL: String?
    public var lat: Double?
    public var lng: Double?
    public var locationName: String?
    public var timezone: String?
    public var website: String?
    public var firstEventID: String?
    public var firstEventCode: String?
    public var webcasts: [TBAWebcast]?
    public var divisionKeys: [String]
    public var parentEventKey: String?
    public var playoffType: Int?
    public var playoffTypeString: String?

    public init(key: String, name: String, eventCode: String, eventType: Int, district: TBADistrict? = nil, city: String? = nil, stateProv: String? = nil, country: String? = nil, startDate: Date, endDate: Date, year: Int, shortName: String? = nil, eventTypeString: String, week: Int? = nil, address: String? = nil, postalCode: String? = nil, gmapsPlaceID: String? = nil, gmapsURL: String? = nil, lat: Double? = nil, lng: Double? = nil, locationName: String? = nil, timezone: String? = nil, website: String? = nil, firstEventID: String? = nil, firstEventCode: String? = nil, webcasts: [TBAWebcast]? = nil, divisionKeys: [String], parentEventKey: String? = nil, playoffType: Int? = nil, playoffTypeString: String? = nil) {
        self.key = key
        self.name = name
        self.eventCode = eventCode
        self.eventType = eventType
        self.district = district
        self.city = city
        self.stateProv = stateProv
        self.country = country
        self.startDate = startDate
        self.endDate = endDate
        self.year = year
        self.shortName = shortName
        self.eventTypeString = eventTypeString
        self.week = week
        self.address = address
        self.postalCode = postalCode
        self.gmapsPlaceID = gmapsPlaceID
        self.gmapsURL = gmapsURL
        self.lat = lat
        self.lng = lng
        self.locationName = locationName
        self.timezone = timezone
        self.website = website
        self.firstEventID = firstEventID
        self.firstEventCode = firstEventCode
        self.webcasts = webcasts
        self.divisionKeys = divisionKeys
        self.parentEventKey = parentEventKey
        self.playoffType = playoffType
        self.playoffTypeString = playoffTypeString
    }

    init?(json: [String: Any]) {
        // Required: key, name, eventCode, eventType startDate, endDate, year
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key

        guard let name = json["name"] as? String else {
            return nil
        }
        self.name = name
        
        guard let eventCode = json["event_code"] as? String else {
            return nil
        }
        self.eventCode = eventCode
        
        guard let eventType = json["event_type"] as? Int else {
            return nil
        }
        self.eventType = eventType

        if let districtJSON = json["district"] as? [String: Any] {
            self.district = TBADistrict(json: districtJSON)
        }

        self.city = json["city"] as? String
        self.stateProv = json["state_prov"] as? String
        self.country = json["country"] as? String

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDateString = json["start_date"] as? String, let startDate = dateFormatter.date(from: startDateString) else {
            return nil
        }
        self.startDate = startDate

        guard let endDateString = json["end_date"] as? String, let endDate = dateFormatter.date(from: endDateString) else {
            return nil
        }
        self.endDate = endDate
        
        guard let year = json["year"] as? Int else {
            return nil
        }
        self.year = year

        self.shortName = json["short_name"] as? String

        guard let eventTypeString = json["event_type_string"] as? String else {
            return nil
        }
        self.eventTypeString = eventTypeString

        self.week = json["week"] as? Int
        self.address = json["address"] as? String
        self.postalCode = json["postal_code"] as? String
        self.gmapsPlaceID = json["gmaps_place_id"] as? String
        self.gmapsURL = json["gmaps_url"] as? String
        self.lat = json["lat"] as? Double
        self.lng = json["lng"] as? Double
        self.locationName = json["location_name"] as? String
        self.timezone = json["timezone"] as? String
        self.website = json["website"] as? String
        self.firstEventID = json["first_event_id"] as? String
        self.firstEventCode = json["first_event_code"] as? String

        var webcasts: [TBAWebcast] = []
        if let webcastJSON = json["webcasts"] as? [[String: Any]] {
            for result in webcastJSON {
                if let webcast = TBAWebcast(json: result) {
                    webcasts.append(webcast)
                }
            }
        }
        self.webcasts = webcasts

        // API should always return us an empty array if there are no division keys
        // ...but just to be safe...
        if let divisionKeys = json["division_keys"] as? [String] {
            self.divisionKeys = divisionKeys
        } else {
            self.divisionKeys = []
        }

        // Currently checking these for nulls since non-2017 events don't support
        // Might be able to remove after some migrations
        if let parentEventKey = json["parent_event_key"] as? String {
            self.parentEventKey = parentEventKey
        }
        if let playoffType = json["playoff_type"] as? Int {
            self.playoffType = playoffType
        }
        if let playoffTypeString = json["playoff_type_string"] as? String {
            self.playoffTypeString = playoffTypeString
        }
    }
    
}

public struct TBAAlliance: TBAModel {

    public var name: String?
    public var backup: TBAAllianceBackup?
    public var declines: [String]?
    public var picks: [String]
    public var status: TBAAllianceStatus?

    public init(name: String? = nil, backup: TBAAllianceBackup? = nil, declines: [String]? = nil, picks: [String], status: TBAAllianceStatus? = nil) {
        self.name = name
        self.backup = backup
        self.declines = declines
        self.picks = picks
        self.status = status
    }

    init?(json: [String: Any]) {
        // Required: picks
        guard let picks = json["picks"] as? [String] else {
            return nil
        }
        self.picks = picks
        
        self.declines = json["declines"] as? [String]
        self.name = json["name"] as? String
        
        if let backupJSON = json["backup"] as? [String: String] {
            self.backup = TBAAllianceBackup(json: backupJSON)
        }
        
        if let statusJSON = json["status"] as? [String: Any] {
            self.status = TBAAllianceStatus(json: statusJSON)
        }
    }
    
}

public struct TBAAllianceBackup: TBAModel {
    
    public var teamIn: String
    public var teamOut: String

    public init(teamIn: String, teamOut: String) {
        self.teamIn = teamIn
        self.teamOut = teamOut
    }

    init?(json: [String: Any]) {
        // Required: in, out
        guard let teamIn = json["in"] as? String else {
            return nil
        }
        self.teamIn = teamIn
        
        guard let teamOut = json["out"] as? String else {
            return nil
        }
        self.teamOut = teamOut
    }
    
}

public struct TBAAllianceStatus: TBAModel {
    
    public var currentRecord: TBAWLT?
    public var level: String?
    public var playoffAverage: Double?
    public var record: TBAWLT?
    public var status: String?

    public init(currentRecord: TBAWLT? = nil, level: String? = nil, playoffAverage: Double? = nil, record: TBAWLT? = nil, status: String? = nil) {
        self.currentRecord = currentRecord
        self.level = level
        self.playoffAverage = playoffAverage
        self.record = record
        self.status = status
    }

    init?(json: [String: Any]) {
        if let currentRecordJSON = json["current_level_record"] as? [String: Any] {
            self.currentRecord = TBAWLT(json: currentRecordJSON)
        }
        
        self.level = json["level"] as? String
        self.playoffAverage = json["playoff_average"] as? Double
        
        if let recordJSON = json["record"] as? [String: Any] {
            self.record = TBAWLT(json: recordJSON)
        }
        
        self.status = json["status"] as? String
    }
    
}

public struct TBAWLT: TBAModel {

    public var wins: Int
    public var losses: Int
    public var ties: Int

    public init(wins: Int, losses: Int, ties: Int) {
        self.wins = wins
        self.losses = losses
        self.ties = ties
    }

    init?(json: [String: Any]) {
        // Required: wins, losses, ties
        self.wins = json["wins"] as? Int ?? 0
        self.losses = json["losses"] as? Int ?? 0
        self.ties = json["ties"] as? Int ?? 0
    }
    
}

public struct TBAAward: TBAModel {
    
    public var name: String
    public var awardType: Int
    public var eventKey: String
    public var recipients: [TBAAwardRecipient]
    public var year: Int

    public init(name: String, awardType: Int, eventKey: String, recipients: [TBAAwardRecipient], year: Int) {
        self.name = name
        self.awardType = awardType
        self.eventKey = eventKey
        self.recipients = recipients
        self.year = year
    }

    init?(json: [String: Any]) {
        // Required: award_type, event_key, name, year, recipient_list
        guard let name = json["name"] as? String else {
            return nil
        }
        self.name = name
        
        guard let awardType = json["award_type"] as? Int else {
            return nil
        }
        self.awardType = awardType
        
        guard let eventKey = json["event_key"] as? String else {
            return nil
        }
        self.eventKey = eventKey
        
        guard let recipientsJSON = json["recipient_list"] as? [[String: Any]] else {
            return nil;
        }
        var recipients: [TBAAwardRecipient] = []
        for result in recipientsJSON {
            if let recipient = TBAAwardRecipient(json: result) {
                recipients.append(recipient)
            }
        }
        self.recipients = recipients
        
        guard let year = json["year"] as? Int else {
            return nil
        }
        self.year = year
    }
    
}

public struct TBAAwardRecipient: TBAModel, Equatable {
    
    // The TBA team key for the team that was given the award. May be null
    public var teamKey: String?
    // The name of the individual given the award. May be null
    public var awardee: String?

    public init(teamKey: String) {
        self.init(teamKey: teamKey, awardee: nil)
    }

    public init(awardee: String) {
        self.init(teamKey: nil, awardee: awardee)
    }

    public init(teamKey: String?, awardee: String?) {
        self.teamKey = teamKey
        self.awardee = awardee
    }

    init?(json: [String: Any]) {
        self.teamKey = json["team_key"] as? String
        self.awardee = json["awardee"] as? String
    }
    
}

public struct TBAEventRanking: TBAModel {

    public var teamKey: String
    public var rank: Int
    public var dq: Int?
    public var matchesPlayed: Int?
    public var qualAverage: Double?
    public var record: TBAWLT?
    public var extraStats: [NSNumber]?
    public var sortOrders: [NSNumber]?

    public init(teamKey: String, rank: Int, dq: Int? = nil, matchesPlayed: Int? = nil, qualAverage: Double? = nil, record: TBAWLT? = nil, extraStats: [NSNumber]? = nil, sortOrders: [NSNumber]? = nil) {
        self.teamKey = teamKey
        self.rank = rank
        self.dq = dq
        self.matchesPlayed = matchesPlayed
        self.qualAverage = qualAverage
        self.record = record
        self.extraStats = extraStats
        self.sortOrders = sortOrders
    }

    init?(json: [String: Any]) {
        // Required: teamKey, rank
        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey
        
        guard let rank = json["rank"] as? Int else {
            return nil
        }
        self.rank = rank
        
        self.dq = json["dq"] as? Int
        self.matchesPlayed = json["matches_played"] as? Int
        self.qualAverage = json["qual_average"] as? Double
        
        if let recordJSON = json["record"] as? [String: Any] {
            self.record = TBAWLT(json: recordJSON)
        }

        self.extraStats = json["extra_stats"] as? [NSNumber]
        self.sortOrders = json["sort_orders"] as? [NSNumber]
    }
    
}

public struct TBAEventRankingSortOrder: TBAModel {
    
    public var name: String
    public var precision: Int

    public init(name: String, precision: Int) {
        self.name = name
        self.precision = precision
    }

    init?(json: [String: Any]) {
        // Required: name, precision
        guard let name = json["name"] as? String else {
            return nil
        }
        self.name = name
        
        guard let precision = json["precision"] as? Int else {
            return nil
        }
        self.precision = precision
    }
    
}

public struct TBAEventInsights: TBAModel {

    public var qual: [String: Any]?
    public var playoff: [String: Any]?

    public init(qual: [String: Any]? = nil, playoff: [String: Any]? = nil) {
        self.qual = qual
        self.playoff = playoff
    }

    init?(json: [String: Any]) {
        self.qual = json["qual"] as? [String: Any]
        self.playoff = json["playoff"] as? [String: Any]
    }

}

public struct TBAStat: TBAModel {
    
    public var teamKey: String
    public var ccwm: Double
    public var dpr: Double
    public var opr: Double

    public init(teamKey: String, ccwm: Double, dpr: Double, opr: Double) {
        self.teamKey = teamKey
        self.ccwm = ccwm
        self.dpr = dpr
        self.opr = opr
    }

    init?(json: [String: Any]) {
        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey
        
        guard let ccwm = json["ccwm"] as? Double else {
            return nil
        }
        self.ccwm = ccwm

        guard let dpr = json["dpr"] as? Double else {
            return nil
        }
        self.dpr = dpr
        
        guard let opr = json["opr"] as? Double else {
            return nil
        }
        self.opr = opr
    }
    
}

public struct TBAWebcast: TBAModel {

    public var type: String
    public var channel: String
    public var file: String?
    public var date: Date?

    public init(type: String, channel: String, file: String? = nil, date: Date? = nil) {
        self.type = type
        self.channel = channel
        self.file = file
        self.date = date
    }

    init?(json: [String: Any]) {
        // Required: type, channel
        guard let type = json["type"] as? String else {
            return nil
        }
        self.type = type
        
        guard let channel = json["channel"] as? String else {
            return nil
        }
        self.channel = channel

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let dateString = json["date"] as? String, let date = dateFormatter.date(from: dateString) {
            self.date = date
        }

        self.file = json["file"] as? String
    }

}

extension TBAKit {

    public func fetchEvents(completion: @escaping (Result<[TBAEvent], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "events/all"
        return callArray(method: method, completion: completion)
    }

    public func fetchEvents(year: Int, completion: @escaping (Result<[TBAEvent], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "events/\(year)"
        return callArray(method: method, completion: completion)
    }

    public func fetchEvent(key: String, completion: @escaping (Result<TBAEvent?, Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)"
        return callObject(method: method, completion: completion)
    }

    public func fetchEventAlliances(key: String, completion: @escaping (Result<[TBAAlliance], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)/alliances"
        return callArray(method: method, completion: completion)
    }

    public func fetchEventInsights(key: String, completion: @escaping (Result<TBAEventInsights?, Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)/insights"
        return callObject(method: method, completion: completion)
    }

    public func fetchEventTeamStats(key: String, completion: @escaping (Result<[TBAStat], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)/oprs"
        return callDictionary(method: method) { (result, notModified) in
            switch result {
            case .failure(let error):
                completion(.failure(error), notModified)
            case .success(let dictionary):
                var oprs: [String: Double] = [:]
                if let oprsDict = dictionary["oprs"] as? [String: Double] {
                    oprs = oprsDict
                }

                var dprs: [String: Double] = [:]
                if let dprsDict = dictionary["dprs"] as? [String: Double] {
                    dprs = dprsDict
                }

                var ccwms: [String: Double] = [:]
                if let ccwmsDict = dictionary["ccwms"] as? [String: Double] {
                    ccwms = ccwmsDict
                }

                var stats: [TBAStat] = []
                // TODO: Problematic - reduce all 3 keys to get this
                for teamKey in oprs.keys {
                    guard let opr = oprs[teamKey] else {
                        continue
                    }
                    guard let dpr = dprs[teamKey] else {
                        continue
                    }
                    guard let ccwm = ccwms[teamKey] else {
                        continue
                    }

                    let json = ["team_key": teamKey,
                                "opr": opr,
                                "dpr": dpr,
                                "ccwm": ccwm] as [String: Any]

                    if let stat = TBAStat(json: json) {
                        stats.append(stat)
                    }
                }
                completion(.success(stats), notModified)
            }
        }
    }

    public func fetchEventRankings(key: String, completion: @escaping (Result<([TBAEventRanking], [TBAEventRankingSortOrder], [TBAEventRankingSortOrder]), Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)/rankings"
        return callDictionary(method: method, completion: { (result, notModified) in
            switch result {
            case .failure(let error):
                completion(.failure(error), notModified)
            case .success(let dictionary):
                var rankings: [TBAEventRanking] = []
                if let rankingsJSON = dictionary["rankings"] as? [[String: Any]] {
                    rankings = rankingsJSON.compactMap({ (rankingJSON) -> TBAEventRanking? in
                        return TBAEventRanking(json: rankingJSON)
                    })
                }

                var sortOrderInfo: [TBAEventRankingSortOrder] = []
                if let sortOrderInfoJSON = dictionary["sort_order_info"] as? [[String: Any]] {
                    sortOrderInfo = sortOrderInfoJSON.compactMap({ (sortOrderJSON) -> TBAEventRankingSortOrder? in
                        return TBAEventRankingSortOrder(json: sortOrderJSON)
                    })
                }

                var extraStatsInfo: [TBAEventRankingSortOrder] = []
                if let extraStatsInfoJSON = dictionary["extra_stats_info"] as? [[String: Any]] {
                    extraStatsInfo = extraStatsInfoJSON.compactMap({ (extraInfoJSON) -> TBAEventRankingSortOrder? in
                        return TBAEventRankingSortOrder(json: extraInfoJSON)
                    })
                }

                completion(.success((rankings, sortOrderInfo, extraStatsInfo)), notModified)
            }
        })
        
    }

    public func fetchEventDistrictPoints(key: String, completion: @escaping (Result<([TBADistrictEventPoints], [TBADistrictPointsTiebreaker]), Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)/district_points"
        return callDictionary(method: method) { (result, notModified) in
            switch result {
            case .failure(let error):
                completion(.failure(error), notModified)
            case .success(let dictionary):
                var districtPoints: [TBADistrictEventPoints] = []
                if let points = dictionary["points"] as? [String: Any] {
                    districtPoints = points.compactMap({ (teamKey, pointsJSON) -> TBADistrictEventPoints? in
                        // Add teamKey and eventKey to pointsJSON
                        guard var json = pointsJSON as? [String: Any] else {
                            return nil
                        }
                        json["team_key"] = teamKey
                        json["event_key"] = key

                        return TBADistrictEventPoints(json: json)
                    })
                }

                var pointsTiebreakers: [TBADistrictPointsTiebreaker] = []
                if let tiebreakers = dictionary["tiebreakers"] as? [String : Any] {
                    pointsTiebreakers = tiebreakers.compactMap({ (teamKey, tiebreakerJSON) -> TBADistrictPointsTiebreaker? in
                        // Add teamKey to pointsJSON
                        guard var json = tiebreakerJSON as? [String: Any] else {
                            return nil
                        }
                        json["team_key"] = teamKey

                        return TBADistrictPointsTiebreaker(json: json)
                    })
                }

                completion(.success((districtPoints, pointsTiebreakers)), notModified)
            }
        }
    }

    public func fetchEventTeams(key: String, completion: @escaping (Result<[TBATeam], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)/teams"
        return callArray(method: method, completion: completion)
    }

    public func fetchEventStatuses(key: String, completion: @escaping (Result<[TBAEventStatus], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)/teams/statuses"
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

    public func fetchEventMatches(key: String, completion: @escaping (Result<[TBAMatch], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)/matches"
        return callArray(method: method, completion: completion)
    }

    public func fetchEventAwards(key: String, completion: @escaping (Result<[TBAAward], Error>, Bool) -> ()) -> TBAKitOperation {
        let method = "event/\(key)/awards"
        return callArray(method: method, completion: completion)
    }
}
