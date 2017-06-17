//
//  RankingTableViewCell.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/14/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit

class EventRankingTableViewCell: UITableViewCell {
    static let reuseIdentifier = "EventRankingCell"
    public var ranking: EventRanking? {
        didSet {
            guard let ranking = ranking, let team = ranking.team else {
                return
            }
            rankLabel?.text = "Rank \(ranking.rank)"
            numberLabel?.text = "\(team.teamNumber)"
            nameLabel?.text = team.nickname ?? team.fallbackNickname
            if let qualAverage = ranking.qualAverage as? Double {
                rankingPointsLabel?.text = "Avg. \(ranking.qualAverage) Points"
            }
            self.setupWLTLabel(ranking: ranking)
        }
        
    }
    
    func setupWLTLabel(ranking: EventRanking) {
        if let wins = ranking.wins, let losses = ranking.losses, let ties = ranking.ties {
            WLTLabel?.text = "(\(wins)-\(losses)-\(ties))"
        }
        
    }
 
    @IBOutlet public var rankLabel: UILabel?
    @IBOutlet private var numberLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var rankingPointsLabel: UILabel?
    @IBOutlet private var WLTLabel: UILabel?
    
}
