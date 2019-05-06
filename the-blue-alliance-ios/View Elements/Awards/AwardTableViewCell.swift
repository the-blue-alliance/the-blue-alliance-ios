import Foundation
import UIKit

class AwardTableViewCell: UITableViewCell, Reusable {

    var viewModel: AwardCellViewModel? {
        didSet {
            configureCell()
        }
    }
    var teamKeySelected: ((_ teamKey: String) -> Void)?
    private let awardNameLabel = UILabel()
    private let awardInfoStackView = FlexLayoutView()

    // Mark: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        awardNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        awardNameLabel.numberOfLines = 0
        awardNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(awardNameLabel)
        awardNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2).isActive = true
        awardNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        awardNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2).isActive = true

        awardInfoStackView.horizontalSpacing = 10
        awardInfoStackView.verticalSpacing = 10
        awardInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(awardInfoStackView)
        awardInfoStackView.leadingAnchor.constraint(equalTo: awardNameLabel.leadingAnchor).isActive = true
        awardInfoStackView.trailingAnchor.constraint(equalTo: awardNameLabel.trailingAnchor).isActive = true
        awardInfoStackView.topAnchor.constraint(equalToSystemSpacingBelow: awardNameLabel.lastBaselineAnchor, multiplier: 1).isActive = true
        self.bottomAnchor.constraint(equalToSystemSpacingBelow: awardInfoStackView.bottomAnchor, multiplier: 2).isActive = true
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Private Methods

    private func removeAwards() {
        awardInfoStackView.removeAllViews()
    }

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        awardNameLabel.text = viewModel.awardName

        removeAwards()

        for (_, recipient) in viewModel.recipients.enumerated() {
            if let header = recipient.teamNumber, let subHeader = recipient.teamName {
                let button = AwardTeamButton(header: "Team \(header)", subheader: subHeader)

                awardInfoStackView.addView(view: button)
            }
        }
        self.layoutIfNeeded()
    }

    @objc private func recipientTapped(gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag, let recipient = viewModel?.recipients[tag], let teamKey = recipient.teamKey else {
            return
        }
        teamKeySelected?(teamKey)
    }

}
