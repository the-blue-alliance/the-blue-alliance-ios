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
    private let awardsFlexView = FlexLayoutView()
    
    // Mark: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        awardNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        awardNameLabel.numberOfLines = 0
        awardNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(awardNameLabel)
        awardNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        awardNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        awardNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true

        awardsFlexView.horizontalSpacing = 10
        awardsFlexView.verticalSpacing = 10
        awardsFlexView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(awardsFlexView)
        awardsFlexView.leadingAnchor.constraint(equalTo: awardNameLabel.leadingAnchor).isActive = true
        awardsFlexView.trailingAnchor.constraint(equalTo: awardNameLabel.trailingAnchor).isActive = true
        awardsFlexView.topAnchor.constraint(equalToSystemSpacingBelow: awardNameLabel.lastBaselineAnchor, multiplier: 1).isActive = true
        self.bottomAnchor.constraint(equalTo: awardsFlexView.bottomAnchor, constant: 20).isActive = true
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Private Methods

    private func removeAwards() {
        awardsFlexView.removeAllViews()
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

                awardsFlexView.addView(view: button)
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
