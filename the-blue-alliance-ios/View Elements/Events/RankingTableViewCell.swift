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
    
    @IBOutlet public var rankLabel: UILabel?
    @IBOutlet private var numberLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var wltLabel: UILabel?
    @IBOutlet var detailLabel: UILabel!
    
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
            } else if let detailsString = ranking.infoString {
                detailLabel.text = detailsString
            } else {
                detailLabel.isHidden = true
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
    
    public var points: DistrictEventPoints? {
        didSet {
            guard let points = points, let team = points.team else {
                return
            }
            numberLabel?.text = "\(team.teamNumber)"
            nameLabel?.text = team.nickname ?? team.fallbackNickname
            detailLabel?.text = "\(points.total) Points"
            wltLabel?.isHidden = true
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
            wltLabel?.isHidden = true
        }
    }
    
    func setupWLTLabel(ranking: EventRanking) {
        if let record = ranking.record {
            wltLabel?.text = "(\(record.wins)-\(record.losses)-\(record.ties))"
        }
    }
}
