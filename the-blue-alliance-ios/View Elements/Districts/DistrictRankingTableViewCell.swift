//
//  RankingTableViewCell.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/14/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit

class DistrictRankingTableViewCell: UITableViewCell {
    static let reuseIdentifier = "DistrictRankingCell"
    public var ranking: DistrictRanking? {
        didSet {
            guard let ranking = ranking, let team = ranking.team else {
                return
            }
            rankLabel?.text = "Rank \(ranking.rank)"
            numberLabel?.text = "\(team.teamNumber)"
            nameLabel?.text = team.nickname ?? team.fallbackNickname
            detailLabel?.text = "\(ranking.pointTotal) Points"
            
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
            detailLabelWidth?.isActive = false
            detailLabel?.text = String(format: "OPR: %.2f, DPR: %.2f, CCWM: %.2f", teamStat.opr, teamStat.dpr, teamStat.ccwm)
            rankLabel?.isHidden = true
        }
    }
    
    @IBOutlet public var rankLabel: UILabel?
    @IBOutlet private var numberLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var detailLabel: UILabel?
    @IBOutlet private var detailLabelWidth: NSLayoutConstraint?
}
