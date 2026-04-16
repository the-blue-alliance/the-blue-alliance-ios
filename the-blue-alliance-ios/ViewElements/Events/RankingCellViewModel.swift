import Foundation
import TBAAPI
import TBAData

struct RankingCellViewModel {

    let rankText: String?

    let teamNumber: String?
    let teamName: String?

    let detailText: String?
    let wltText: String?

    init(rank: String, apiTeamKey teamKey: String, points: Int) {
        self.rankText = rank
        self.teamNumber = Self.teamNumber(from: teamKey)
        self.teamName = "Team \(self.teamNumber ?? teamKey)"
        self.detailText = "\(points) Points"
        self.wltText = nil
    }

    init(apiRanking ranking: Components.Schemas.EventRanking.RankingsPayloadPayload, detailText: String?) {
        self.rankText = "Rank \(ranking.rank)"
        self.teamNumber = Self.teamNumber(from: ranking.teamKey)
        self.teamName = "Team \(self.teamNumber ?? ranking.teamKey)"
        self.detailText = detailText
        self.wltText = {
            if let qualAverage = ranking.qualAverage {
                return "\(qualAverage)"
            } else if let record = ranking.record {
                return "\(record.wins)-\(record.losses)-\(record.ties)"
            } else {
                return nil
            }
        }()
    }

    // Parses "frc254" → "254". Phase 3 will add nickname lookup.
    private static func teamNumber(from key: String) -> String? {
        key.hasPrefix("frc") ? String(key.dropFirst(3)) : key
    }

    init(districtRanking: DistrictRanking) {
        rankText = "Rank \(districtRanking.rank)"

        teamNumber = String(describing: districtRanking.team.teamNumber)
        teamName = districtRanking.team.nickname ?? districtRanking.team.teamNumberNickname

        detailText = "\(districtRanking.pointTotal) Points"
        wltText = nil
    }

    init(rank: String, districtEventPoints: DistrictEventPoints) {
        rankText = rank

        teamNumber = String(describing: districtEventPoints.team.teamNumber)
        teamName = districtEventPoints.team.nickname ?? districtEventPoints.team.teamNumberNickname

        detailText = "\(districtEventPoints.total) Points"
        wltText = nil
    }

    init(eventRanking: EventRanking) {
        rankText = "Rank \(eventRanking.rank)"

        teamNumber = String(describing: eventRanking.team.teamNumber)
        teamName = eventRanking.team.nickname ?? eventRanking.team.teamNumberNickname

        detailText = eventRanking.rankingInfoString

        wltText = {
            if let qualAverage = eventRanking.qualAverage {
                return "\(qualAverage)"
            } else {
                return eventRanking.record?.stringValue
            }
        }()
    }

    init(eventTeamStat: EventTeamStat) {
        rankText = nil

        teamNumber = String(describing: eventTeamStat.team.teamNumber)
        teamName = eventTeamStat.team.nickname ?? eventTeamStat.team.teamNumberNickname

        detailText = String(format: "OPR: %.2f, DPR: %.2f, CCWM: %.2f", eventTeamStat.opr, eventTeamStat.dpr, eventTeamStat.ccwm)
        wltText = nil
    }

    var hasRank: Bool {
        return rankText != nil
    }

    var hasDetails: Bool {
        // Event rankings will conditionally show details, if we have the proper information
        // If we have a qual average or a ranking info string, we have details
        return detailText != nil
    }

    var hasWLT: Bool {
        return wltText != nil
    }

}
