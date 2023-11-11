import Foundation
import UIKit

class AwardTableViewCell: UITableViewCell, Reusable {

    var viewModel: AwardCellViewModel? {
        didSet {
            configureCell()
        }
    }
    var teamKeySelected: ((_ teamKey: String) -> Void)?

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var awardNameLabel: UILabel!
    @IBOutlet private weak var awardInfoStackView: UIStackView!

    // MARK: - Private Methods

    private func removeAwards() {
        for view in awardInfoStackView.arrangedSubviews {
            awardInfoStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        awardNameLabel.text = viewModel.awardName

        removeAwards()

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
        guard let tag = gesture.view?.tag, let recipient = viewModel?.recipients[tag], let teamKey = recipient.teamKey else {
            return
        }
        teamKeySelected?(teamKey)
    }

}
