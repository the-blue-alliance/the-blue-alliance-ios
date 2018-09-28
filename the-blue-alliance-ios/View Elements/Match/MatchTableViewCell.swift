import Foundation
import UIKit

class MatchTableViewCell: UITableViewCell {
    static let reuseIdentifier = "MatchCell"

    var matchViewModel: MatchCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Interface Builder

    private let winnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
    private let notWinnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)

    @IBOutlet private var matchNumberLabel: UILabel!

    @IBOutlet private var redStackView: UIStackView!
    @IBOutlet private var redContainerView: UIView!
    @IBOutlet private var redScoreLabel: UILabel!

    @IBOutlet private var blueStackView: UIStackView!
    @IBOutlet private var blueContainerView: UIView!
    @IBOutlet private var blueScoreLabel: UILabel!

    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var playIconImageView: UIImageView!

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
    public static func label(for team: Team, baseTeam: Team?) -> UILabel {
        let label = UILabel()
        label.text = "\(team.teamNumber)"
        var font: UIFont = .systemFont(ofSize: 14)
        if team.teamNumber == baseTeam?.teamNumber {
            font = .boldSystemFont(ofSize: 14)
        }
        label.font = font
        label.textAlignment = .center
        return label
    }

    // MARK: - Private Methods

    private func configureCell() {
        guard let matchViewModel = matchViewModel else {
            return
        }

        matchNumberLabel.text = matchViewModel.matchName
        playIconImageView.isHidden = matchViewModel.hasVideos

        for team in matchViewModel.redAlliance {
            let teamLabel = MatchTableViewCell.label(for: team, baseTeam: matchViewModel.team)
            redStackView.insertArrangedSubview(teamLabel, at: 0)
        }
        redScoreLabel.text = matchViewModel.redScore

        for team in matchViewModel.blueAlliance {
            let teamLabel = MatchTableViewCell.label(for: team, baseTeam: matchViewModel.team)
            blueStackView.insertArrangedSubview(teamLabel, at: 0)
        }
        blueScoreLabel.text = matchViewModel.blueScore

        timeLabel.isHidden = matchViewModel.hasScores
        timeLabel.text = matchViewModel.timeString

        if matchViewModel.redAllianceWon {
            redContainerView.layer.borderWidth = 2.0
            redScoreLabel.font = winnerFont
        } else if matchViewModel.blueAllianceWon {
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
