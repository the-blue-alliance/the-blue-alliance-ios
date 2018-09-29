import Foundation
import UIKit

class EventAllianceTableViewCell: UITableViewCell {

    static let reuseIdentifier = "EventAllianceCell"

    var viewModel: EventAllianceCellViewModel? {
        didSet {
            configureCell()
        }
    }
    var teamSelected: ((_ teamKey: String) -> Void)?

    // MARK: - Interface Builder

    @IBOutlet private weak var levelLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var allianceTeamsStackView: UIStackView!

    // MARK: - UI

    private let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]

    // MARK: - View Methods

    override func prepareForReuse() {
        super.prepareForReuse()

        for view in allianceTeamsStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

    // MARK: - Private Methods

    private func labelWithText(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }

    private func underlinedLabelWithText(_ text: String) -> UILabel {
        let label = labelWithText(text)
        let underlineAttributedString = NSAttributedString(string: text, attributes: underlineAttribute)
        label.attributedText = underlineAttributedString
        return label
    }

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        levelLabel.isHidden = !viewModel.hasAllianceLevel
        levelLabel.text = viewModel.allianceLevel

        nameLabel.isHidden = !viewModel.hasAllianceName
        nameLabel.text = viewModel.allianceName

        // OH PICK BOY http://photos.prnewswire.com/prnvar/20140130/NY56077
        for (index, teamKey) in viewModel.picks.enumerated() {
            let teamNumber = Team.trimFRCPrefix(teamKey)

            var label: UILabel
            if index == 0 {
                label = underlinedLabelWithText(teamNumber)
            } else {
                label = labelWithText(teamNumber)
            }
            label.tag = index

            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(teamTapped(gesture:))))
            allianceTeamsStackView.addArrangedSubview(label)
        }
    }

    @objc private func teamTapped(gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag, let picks = viewModel?.picks, index < picks.count else {
            return
        }

        let teamKey = picks[index]
        teamSelected?(teamKey)
    }

}
