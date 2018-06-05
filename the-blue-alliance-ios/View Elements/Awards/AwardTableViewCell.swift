import Foundation
import UIKit

class AwardTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AwardCell"
    public var award: Award? {
        didSet {
            recipients = award?.recipients?.allObjects as? [AwardRecipient]
            configureCell()
        }
    }
    private var recipients: [AwardRecipient]?

    var teamSelected: ((Team) -> Void)?
    @IBOutlet private weak var awardNameLabel: UILabel!
    @IBOutlet private weak var awardInfoStackView: UIStackView!

    private func configureCell() {
        awardNameLabel.text = award?.name

        for view in awardInfoStackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        guard let recipients = recipients else {
            return
        }

        for (index, recipient) in recipients.enumerated() {
            if recipient.awardText.count == 0 {
                continue
            }

            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.tag = index
            stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recipientTapped(gesture:))))
            for text in recipient.awardText {
                let label = boldLabelWithText(text)
                stackView.addArrangedSubview(label)
            }
            awardInfoStackView.addArrangedSubview(stackView)
        }
    }

    private func boldLabelWithText(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }

    @objc private func recipientTapped(gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag, let recipient = recipients?[tag], let team = recipient.team else {
            return
        }
        if let teamSelected = teamSelected {
            teamSelected(team)
        }
    }

}
