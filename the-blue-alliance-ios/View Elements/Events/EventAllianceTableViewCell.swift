import Foundation
import UIKit

class EventAllianceTableViewCell: UITableViewCell {
    private let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
    
    static let reuseIdentifier = "EventAllianceCell"
    public var alliance: EventAlliance? {
        didSet {
            configureCell()
        }
    }
    var teamSelected: ((Team) -> ())?

    @IBOutlet private var levelLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var allianceTeamsStackView: UIStackView!
    
    private func labelWithText(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        return label
    }
    
    private func underlinedLabelWithText(_ text: String) -> UILabel {
        let label = labelWithText(text)
        let underlineAttributedString = NSAttributedString(string: text, attributes: underlineAttribute)
        label.attributedText = underlineAttributedString
        return label
    }
    
    private func configureCell() {
        for view in allianceTeamsStackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        guard let alliance = alliance else {
            return
        }
        
        if let status = alliance.status, let allianceLevel = status.allianceLevel {
            levelLabel.text = allianceLevel
            levelLabel.isHidden = false
        } else {
            levelLabel.isHidden = true
        }
        
        if let name = alliance.name {
            nameLabel.text = name
            nameLabel.isHidden = false
        } else {
            nameLabel.isHidden = true
        }
        
        // TODO: Find a way to type these sorts of to-many relationships in Swift/Core Data
        guard let picks = alliance.picks as? NSMutableOrderedSet else {
            return
        }
        
        // OH PICK BOY http://photos.prnewswire.com/prnvar/20140130/NY56077
        for (index, team) in picks.enumerated() {
            guard let team = team as? Team else {
                continue
            }
            let teamNumber = "\(team.teamNumber)"

            var label: UILabel
            if index == 0 {
                label = underlinedLabelWithText(teamNumber)
            } else {
                label = labelWithText(teamNumber)
            }
            label.textAlignment = .center
            label.tag = index
            label.isUserInteractionEnabled = true
            
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(teamTapped(gesture:))))
            allianceTeamsStackView.addArrangedSubview(label)
        }
    }
    
    @objc private func teamTapped(gesture: UITapGestureRecognizer) {
        guard let teamSelected = teamSelected else {
            return
        }
        
        guard let index = gesture.view?.tag, let picks = alliance?.picks?.array as? [Team], index < picks.count else {
            return
        }

        let team = picks[index]
        teamSelected(team)
    }
}
