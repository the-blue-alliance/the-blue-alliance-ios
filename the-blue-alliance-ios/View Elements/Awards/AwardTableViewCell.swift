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
        awardNameLabel.setContentHuggingPriority(UILayoutPriority(998), for: .vertical)

        awardsFlexView.horizontalSpacing = 10
        awardsFlexView.verticalSpacing = 10
        awardsFlexView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(awardsFlexView)
        awardsFlexView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        awardsFlexView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        awardsFlexView.topAnchor.constraint(equalToSystemSpacingBelow: awardNameLabel.lastBaselineAnchor, multiplier: 1).isActive = true
        awardsFlexView.setContentHuggingPriority(UILayoutPriority(999), for: .vertical)
        self.bottomAnchor.constraint(equalTo: awardsFlexView.bottomAnchor, constant: 20).withPriority(.defaultHigh).isActive = true
        self.setContentHuggingPriority(UILayoutPriority(999), for: .vertical)
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

        for (index, recipient) in viewModel.recipients.enumerated() {
            var viewToAdd = UIView()
            if let teamNumber = recipient.teamNumber, let awardee = recipient.awardee {
                let button = AwardTeamButton(header: teamNumber, subheader: recipient.teamName ?? "", widthRange: (UIScreen.main.bounds.width * 0.3)...(UIScreen.main.bounds.width * 0.4))
                viewToAdd = TeamButtonWithAwardee(teamButton: button, awardee: awardee)
            }
            else if let teamNumber = recipient.teamNumber {
                viewToAdd = AwardTeamButton(header: teamNumber, subheader: recipient.teamName ?? "", widthRange: (UIScreen.main.bounds.width * 0.3)...(UIScreen.main.bounds.width * 0.4))
            }
            else if let awardee = recipient.awardee {
                let label = UILabel()
                label.text = awardee
                label.font = .italicSystemFont(ofSize: 14)
                label.translatesAutoresizingMaskIntoConstraints = false
                viewToAdd = label
            }

            viewToAdd.tag = index
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(recipientTapped(gesture:)))
            viewToAdd.addGestureRecognizer(tapGestureRecognizer)
            awardsFlexView.addView(view: viewToAdd)
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

class TeamButtonWithAwardee: UIView {

    private let teamButton: AwardTeamButton
    private let awardeeLabel: UILabel

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: max(awardeeLabel.intrinsicContentSize.width, teamButton.intrinsicContentSize.width), height: awardeeLabel.intrinsicContentSize.height + teamButton.intrinsicContentSize.height + 5)
        }
    }

    // Mark: - Init

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    init(teamButton: AwardTeamButton, awardee: String) {
        self.teamButton = teamButton
        self.awardeeLabel = UILabel()
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)

        awardeeLabel.text = awardee
        awardeeLabel.font = .italicSystemFont(ofSize: 14)
        awardeeLabel.textColor = .black
        awardeeLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(awardeeLabel)
        self.addSubview(teamButton)

        awardeeLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        awardeeLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true

        teamButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        teamButton.topAnchor.constraint(equalTo: awardeeLabel.bottomAnchor, constant: 5).isActive = true
        self.invalidateIntrinsicContentSize()
    }

}
