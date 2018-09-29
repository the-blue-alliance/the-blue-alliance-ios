import Foundation

struct RankingCellViewModel {

    let rankText: String?

    let teamNumber: String?
    let teamName: String?

    let detailText: String?
    let wltText: String?

    init(districtRanking: DistrictRanking) {
        rankText = "Rank \(districtRanking.rank)"

        teamNumber = String(describing: districtRanking.team!.teamNumber)
        teamName = districtRanking.team!.nickname ?? districtRanking.team!.fallbackNickname

        detailText = "\(districtRanking.pointTotal) Points"
        wltText = nil
    }

    init(rank: String, districtEventPoints: DistrictEventPoints) {
        rankText = rank

        teamNumber = String(describing: districtEventPoints.team!.teamNumber)
        teamName = districtEventPoints.team?.nickname ?? districtEventPoints.team?.fallbackNickname

        detailText = "\(districtEventPoints.total) Points"
        wltText = nil
    }

    init(eventRanking: EventRanking) {
        rankText = "Rank \(eventRanking.rank)"

        teamNumber = String(describing: eventRanking.team!.teamNumber)
        teamName = eventRanking.team!.nickname ?? eventRanking.team!.fallbackNickname

        detailText = {
            if let qualAverage = eventRanking.qualAverage {
                return "Avg. \(qualAverage.doubleValue) Points"
            } else if let rankingInfoString = eventRanking.infoString {
                return rankingInfoString
            }
            return nil
        }()
        wltText = eventRanking.record?.displayString()
    }

    init(eventTeamStat: EventTeamStat) {
        rankText = nil

        teamNumber = String(describing: eventTeamStat.team!.teamNumber)
        teamName = eventTeamStat.team!.nickname ?? eventTeamStat.team!.fallbackNickname

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
