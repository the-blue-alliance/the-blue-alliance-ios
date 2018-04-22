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
    var teamSelected: ((String) -> ())?

    @IBOutlet private var levelLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var allianceTeamsStackView: UIStackView!
    
    private func labelWithText(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        return label
    }
    
    private func boldLabelWithText(_ text: String) -> UILabel {
        let label = labelWithText(text)
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.semibold)
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
        
        // OH PICK BOY http://photos.prnewswire.com/prnvar/20140130/NY56077
        for (index, teamKey) in alliance.picks!.enumerated() {
            let teamNumber = Team.trimFRCPrefix(teamKey)

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
        guard let index = gesture.view?.tag, let picks = alliance?.picks, index < picks.count else {
            return
        }
        let teamKey = picks[index]
        if let teamSelected = teamSelected {
            teamSelected(teamKey)
        }
    }
}
