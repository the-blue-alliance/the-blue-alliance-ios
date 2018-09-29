import Foundation
import UIKit

class AwardTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AwardCell"

    var viewModel: AwardCellViewModel? {
        didSet {
            configureCell()
        }
    }
    var teamSelected: ((_ teamKey: String) -> Void)?

    // MARK: - Interface Builder

    @IBOutlet private weak var awardNameLabel: UILabel!
    @IBOutlet private weak var awardInfoStackView: UIStackView!

    // MARK: - View Methods

    override func prepareForReuse() {
        for view in awardInfoStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        awardNameLabel.text = viewModel.awardName

        for (index, recipient) in viewModel.recipients.enumerated() {
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
        guard let tag = gesture.view?.tag, let recipient = viewModel?.recipients[tag], let team = recipient.teamKey else {
            return
        }
        teamSelected?(team)
    }

}
