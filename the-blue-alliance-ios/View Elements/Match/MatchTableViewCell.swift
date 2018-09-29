import Foundation
import UIKit

class MatchTableViewCell: UITableViewCell, Reusable {

    var viewModel: MatchCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    private let winnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
    private let notWinnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)

    @IBOutlet private weak var matchNumberLabel: UILabel!

    @IBOutlet private weak var redStackView: UIStackView!
    @IBOutlet private weak var redContainerView: UIView!
    @IBOutlet private weak var redScoreLabel: UILabel!

    @IBOutlet private weak var blueStackView: UIStackView!
    @IBOutlet private weak var blueContainerView: UIView!
    @IBOutlet private weak var blueScoreLabel: UILabel!

    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var playIconImageView: UIImageView!

    private var coloredViews: [UIView] {
        return [redContainerView, redScoreLabel, blueContainerView, blueScoreLabel, timeLabel]
    }

    // MARK: - View Methods

    override func awakeFromNib() {
        redContainerView.layer.borderColor = UIColor.red.cgColor
        blueContainerView.layer.borderColor = UIColor.blue.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let colors = storeBaseColors(for: coloredViews)
        super.setSelected(selected, animated: animated)

        if selected {
            restoreBaseColors(colors, for: coloredViews)
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let colors = storeBaseColors(for: coloredViews)
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            restoreBaseColors(colors, for: coloredViews)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        for stackView in [redStackView, blueStackView] as [UIStackView] {
            for view in stackView.arrangedSubviews {
                if [redScoreLabel, blueScoreLabel].contains(view) {
                    continue
                }
                view.removeFromSuperview()
            }
        }

        redContainerView.layer.borderWidth = 0.0
        blueContainerView.layer.borderWidth = 0.0

        redScoreLabel.font = notWinnerFont
        blueScoreLabel.font = notWinnerFont
    }

    // MARK: - Public Methods

    // TODO: For the love of god, move this literally anywhere else
    public static func label(for teamKey: String, baseTeamKey: String?) -> UILabel {
        let label = UILabel()
        label.text = "\(Team.trimFRCPrefix(teamKey))"
        var font: UIFont = .systemFont(ofSize: 14)
        if teamKey == baseTeamKey {
            font = .boldSystemFont(ofSize: 14)
        }
        label.font = font
        label.textAlignment = .center
        return label
    }

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        matchNumberLabel.text = viewModel.matchName
        playIconImageView.isHidden = viewModel.hasVideos

        for teamKey in viewModel.redAlliance {
            let teamLabel = MatchTableViewCell.label(for: teamKey, baseTeamKey: viewModel.baseTeamKey)
            redStackView.insertArrangedSubview(teamLabel, at: 0)
        }
        redScoreLabel.text = viewModel.redScore

        for teamKey in viewModel.blueAlliance {
            let teamLabel = MatchTableViewCell.label(for: teamKey, baseTeamKey: viewModel.baseTeamKey)
            blueStackView.insertArrangedSubview(teamLabel, at: 0)
        }
        blueScoreLabel.text = viewModel.blueScore

        timeLabel.isHidden = viewModel.hasScores
        timeLabel.text = viewModel.timeString

        if viewModel.redAllianceWon {
            redContainerView.layer.borderWidth = 2.0
            redScoreLabel.font = winnerFont
        } else if viewModel.blueAllianceWon {
            blueContainerView.layer.borderWidth = 2.0
            blueScoreLabel.font = winnerFont
        }
    }

    private func storeBaseColors(for views: [UIView]) -> [UIColor] {
        var colors: [UIColor] = []
        for view in views {
            colors.append(view.backgroundColor!)
        }
        return colors
    }

    private func restoreBaseColors(_ colors: [UIColor], for views: [UIView]) {
        if colors.count != views.count {
            return
        }

        for (index, view) in views.enumerated() {
            view.backgroundColor = colors[index]
        }
    }

}
