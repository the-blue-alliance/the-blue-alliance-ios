import Foundation
import UIKit

class MatchView: UIView {

    var viewModel: MatchViewModel? {
        didSet {
            configureView()
        }
    }

    private let winnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
    private let notWinnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)

    // MARK: - IBOutlet

    @IBOutlet private var matchView: UIView!

    @IBOutlet weak var matchInfoStackView: UIStackView!
    @IBOutlet private weak var matchNumberLabel: UILabel!
    @IBOutlet weak private var playIconImageView: UIImageView!

    @IBOutlet private weak var redStackView: UIStackView!
    @IBOutlet weak var redContainerView: UIView! {
        didSet {
            redContainerView.layer.borderColor = UIColor.red.cgColor
        }
    }
    @IBOutlet weak var redScoreLabel: UILabel!

    @IBOutlet weak private var blueStackView: UIStackView!
    @IBOutlet weak var blueContainerView: UIView! {
        didSet {
            blueContainerView.layer.borderColor = UIColor.blue.cgColor
        }
    }
    @IBOutlet weak var blueScoreLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        initMatchView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initMatchView()
    }

    func initMatchView() {
        Bundle.main.loadNibNamed(String(describing: MatchView.self), owner: self, options: nil)
        matchView.frame = self.bounds
        matchView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(matchView)
    }

    // MARK: - Public Methods

    func resetView() {
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

    // MARK: - Private Methods

    private func configureView() {
        guard let viewModel = viewModel else {
            return
        }

        matchNumberLabel.text = viewModel.matchName
        playIconImageView.isHidden = viewModel.hasVideos

        for teamKey in viewModel.redAlliance {
            let teamLabel = label(for: teamKey, baseTeamKey: viewModel.baseTeamKey)
            redStackView.insertArrangedSubview(teamLabel, at: 0)
        }
        redScoreLabel.text = viewModel.redScore

        for teamKey in viewModel.blueAlliance {
            let teamLabel = label(for: teamKey, baseTeamKey: viewModel.baseTeamKey)
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

    private func label(for teamKey: String, baseTeamKey: String?) -> UILabel {
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

}
