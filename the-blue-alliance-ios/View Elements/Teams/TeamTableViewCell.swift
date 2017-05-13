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
            
            if let location = team.locationName {
                locationLabel?.text = location
            } else {
                locationLabel?.text = [team.city, team.state, team.country].reduce("", { (locationString, locationPart) -> String in
                    guard let locationPart = locationPart else {
                        return locationString
                    }
                    return locationString.isEmpty ? locationPart : "\(locationString), \(locationPart)"
                })
            }
        }
        
    }
    
    @IBOutlet private var numberLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var locationLabel: UILabel?
}
