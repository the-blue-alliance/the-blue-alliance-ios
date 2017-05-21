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
 
    @IBOutlet public var rankLabel: UILabel?
    @IBOutlet private var numberLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var detailLabel: UILabel?
}
