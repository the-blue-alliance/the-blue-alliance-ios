import Foundation
import TBAAPI

struct RankingCellViewModel {

    let rankText: String?

    let teamNumber: String?
    let teamName: String?

    let detailText: String?
    let wltText: String?

    init(ranking: DistrictRanking, team: TeamSimple? = nil) {
        self.rankText = "Rank \(ranking.rank)"
        self.teamNumber = Self.teamNumber(from: ranking.teamKey)
        self.teamName = team?.displayNickname ?? "Team \(self.teamNumber ?? ranking.teamKey)"
        self.detailText = "\(ranking.pointTotal) Points"
        self.wltText = nil
    }

    init(rank: String, teamKey: String, points: Int, team: TeamSimple? = nil) {
        self.rankText = rank
        self.teamNumber = Self.teamNumber(from: teamKey)
        self.teamName = team?.displayNickname ?? "Team \(self.teamNumber ?? teamKey)"
        self.detailText = "\(points) Points"
        self.wltText = nil
    }

    init(
        teamKey: String,
        opr: Float,
        dpr: Float,
        ccwm: Float,
        team: TeamSimple? = nil
    ) {
        self.rankText = nil
        self.teamNumber = Self.teamNumber(from: teamKey)
        self.teamName = team?.displayNickname ?? "Team \(self.teamNumber ?? teamKey)"
        self.detailText = String(format: "OPR: %.2f, DPR: %.2f, CCWM: %.2f", opr, dpr, ccwm)
        self.wltText = nil
    }

    init(
        ranking: EventRanking.RankingsPayloadPayload,
        detailText: String?,
        team: TeamSimple? = nil
    ) {
        self.rankText = "Rank \(ranking.rank)"
        self.teamNumber = Self.teamNumber(from: ranking.teamKey)
        self.teamName = team?.displayNickname ?? "Team \(self.teamNumber ?? ranking.teamKey)"
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

    private static func teamNumber(from key: String) -> String? {
        key.hasPrefix("frc") ? String(key.dropFirst(3)) : key
    }

    var hasRank: Bool {
        return rankText != nil
    }

    var hasDetails: Bool {
        return detailText != nil
    }

    var hasWLT: Bool {
        return wltText != nil
    }

}
