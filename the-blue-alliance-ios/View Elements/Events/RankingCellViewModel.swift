import Foundation

struct RankingCellViewModel {

    let rankText: String?

    let teamNumber: String?
    let teamName: String?

    let detailText: String?
    let wltText: String?

    init(districtRanking: DistrictRanking) {
        rankText = "Rank \(districtRanking.rank!.stringValue)"

        teamNumber = String(describing: districtRanking.teamKey!.teamNumber)
        teamName = districtRanking.teamKey!.team?.nickname ?? districtRanking.teamKey!.name

        detailText = "\(districtRanking.pointTotal!.stringValue) Points"
        wltText = nil
    }

    init(rank: String, districtEventPoints: DistrictEventPoints) {
        rankText = rank

        teamNumber = String(describing: districtEventPoints.teamKey!.teamNumber)
        teamName = districtEventPoints.teamKey!.team?.nickname ?? districtEventPoints.teamKey!.name

        detailText = "\(districtEventPoints.total!.stringValue) Points"
        wltText = nil
    }

    init(eventRanking: EventRanking) {
        rankText = "Rank \(eventRanking.rank!.intValue)"

        teamNumber = String(describing: eventRanking.teamKey!.teamNumber)
        teamName = eventRanking.teamKey!.team?.nickname ?? eventRanking.teamKey!.name

        detailText = {
            if let qualAverage = eventRanking.qualAverage {
                return "Avg. \(qualAverage.doubleValue) Points"
            } else if let tiebreakerInfoString = eventRanking.tiebreakerInfoString {
                var rpIndex : Int? = nil
                var isAvg = false
                
                var rpString = ""
                
                if(eventRanking.extraStatsNames != nil){
                    for (index, element) in eventRanking.extraStatsNames!.enumerated() {
                        if(element == "Total Ranking Points"){
                            rpString = element
                            rpIndex = index;
                        } else if(element == "Ranking Score/Match" || element == "Qual Score/Match"){
                            rpString = element
                            rpIndex = index;
                            isAvg = true
                        }
                    }
                }
                
                var rpTotal : NSNumber = -1
                
                if(rpIndex != nil){
                    if var rp = eventRanking.extraStatsValues?[rpIndex!] {
                        if(isAvg){
                            rp = NSNumber(value: Double(round(100*rp.doubleValue)/100))
                        }
                        rpTotal = rp
                    }
                }
                
                if(rpString != "" && rpTotal.intValue >= 0){
                    return "\(rpString): \(rpTotal), \(tiebreakerInfoString)"
                } else {
                    return tiebreakerInfoString
                }
            }
            return nil
        }()
        wltText = eventRanking.record?.displayString()
    }

    init(eventTeamStat: EventTeamStat) {
        rankText = nil

        teamNumber = eventTeamStat.teamKey!.teamNumber
        teamName = eventTeamStat.teamKey!.team?.nickname ?? eventTeamStat.teamKey!.name

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
