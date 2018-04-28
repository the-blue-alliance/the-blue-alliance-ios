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
            nameLabel?.text = team.nickname ?? team.fallbackNickname
            locationLabel?.text = team.locationString
        }
        
    }
    
    @IBOutlet private var numberLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var locationLabel: UILabel?
}
