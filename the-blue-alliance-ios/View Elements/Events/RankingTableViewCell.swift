//
//  RankingTableViewCell.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/14/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit

class RankingTableViewCell: UITableViewCell {
    static let reuseIdentifier = "RankingCell"
    public var eventRanking: EventRanking? {
        didSet {
            guard let ranking = eventRanking, let team = ranking.team else {
                return
            }
            rankLabel?.text = "Rank \(ranking.rank)"
            numberLabel?.text = "\(team.teamNumber)"
            nameLabel?.text = team.nickname ?? team.fallbackNickname
            if let qualAverage = ranking.qualAverage as? Double {
                detailLabel?.text = "Avg. \(qualAverage) Points"
            }
            setupWLTLabel(ranking: ranking)
        }
    }
    
    public var districtRanking: DistrictRanking? {
        didSet {
            guard let ranking = districtRanking, let team = ranking.team else {
                return
            }
            rankLabel?.text = "Rank \(ranking.rank)"
            numberLabel?.text = "\(team.teamNumber)"
            nameLabel?.text = team.nickname ?? team.fallbackNickname
            detailLabel?.text = "\(ranking.pointTotal) Points"
            wltLabel?.isHidden = true
        }
    }
    
    public var points: EventPoints? {
        didSet {
            guard let points = points, let team = points.team else {
                return
            }
            numberLabel?.text = "\(team.teamNumber)"
            nameLabel?.text = team.nickname ?? team.fallbackNickname
            detailLabel?.text = "\(points.total) Points"
        }
    }
    
    public var teamStat: EventTeamStat? {
        didSet {
            guard let teamStat = teamStat, let team = teamStat.team else {
                return
            }
            numberLabel?.text = "\(team.teamNumber)"
            nameLabel?.text = team.nickname ?? team.fallbackNickname
            detailLabel?.text = String(format: "OPR: %.2f, DPR: %.2f, CCWM: %.2f", teamStat.opr, teamStat.dpr, teamStat.ccwm)
            rankLabel?.isHidden = true
        }
    }
    
    func setupWLTLabel(ranking: EventRanking) {
        if let wins = ranking.wins, let losses = ranking.losses, let ties = ranking.ties {
            wltLabel?.text = "(\(wins)-\(losses)-\(ties))"
        }
    }
 
    @IBOutlet public var rankLabel: UILabel?
    @IBOutlet private var numberLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var wltLabel: UILabel?
    @IBOutlet var detailLabel: UILabel!
    
}
