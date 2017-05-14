//
//  TeamTableViewCell.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/12/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit

class TeamTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TeamCell"
    public var team: Team? {
        didSet {
            guard let team = team else {
                return
            }
            numberLabel?.text = "\(team.teamNumber)"
            nameLabel?.text = (team.nickname != nil ? team.nickname : team.name)
            locationLabel?.text = team.locationString
        }
        
    }
    
    @IBOutlet private var numberLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var locationLabel: UILabel?
}
