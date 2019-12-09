import Foundation
import TBAData

struct RankingCellViewModel {

    let rankText: String?

    let teamNumber: String?
    let teamName: String?

    let detailText: String?
    let wltText: String?

    init(districtRanking: DistrictRanking) {
        rankText = "Rank \(districtRanking.rank!.stringValue)"

        teamNumber = String(describing: districtRanking.team!.teamNumber) // TODO: Make sure this isn't nil....
        teamName = districtRanking.team!.nickname ?? districtRanking.team!.fallbackNickname

        detailText = "\(districtRanking.pointTotal!.stringValue) Points"
        wltText = nil
    }

    init(rank: String, districtEventPoints: DistrictEventPoints) {
        rankText = rank

        teamNumber = String(describing: districtEventPoints.team!.teamNumber)
        teamName = districtEventPoints.team!.nickname ?? districtEventPoints.team!.fallbackNickname

        detailText = "\(districtEventPoints.total!.stringValue) Points"
        wltText = nil
    }

    init(eventRanking: EventRanking) {
        rankText = "Rank \(eventRanking.rank!.intValue)"

        teamNumber = String(describing: eventRanking.team!.teamNumber) // TODO: Make sure this isn't nil...
        teamName = eventRanking.team!.nickname ?? eventRanking.team!.fallbackNickname

        detailText = eventRanking.rankingInfoString

        wltText = {
            if let qualAverage = eventRanking.qualAverage {
                return qualAverage.stringValue
            } else {
                return eventRanking.record?.stringValue
            }
        }()
    }

    init(eventTeamStat: EventTeamStat) {
        rankText = nil

        teamNumber = String(describing: eventTeamStat.team!.teamNumber) // TODO: Make sure this isn't nil
        teamName = eventTeamStat.team!.nickname ?? eventTeamStat.team!.fallbackNickname

        detailText = String(format: "OPR: %.2f, DPR: %.2f, CCWM: %.2f", eventTeamStat.opr!.floatValue, eventTeamStat.dpr!.floatValue, eventTeamStat.ccwm!.floatValue)
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
