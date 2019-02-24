import Foundation
import UIKit

class MatchSummaryView: UIView {

    var viewModel: MatchViewModel? {
        didSet {
            configureView()
        }
    }

    private let winnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
    private let notWinnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)

    // MARK: - IBOutlet

    @IBOutlet private var summaryView: UIView!

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
    @IBOutlet private weak var redRPStackView: UIStackView!

    @IBOutlet weak private var blueStackView: UIStackView!
    @IBOutlet weak var blueContainerView: UIView! {
        didSet {
            blueContainerView.layer.borderColor = UIColor.blue.cgColor
        }
    }
    @IBOutlet weak var blueScoreLabel: UILabel!
    @IBOutlet private weak var blueRPStackView: UIStackView!

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
        Bundle.main.loadNibNamed(String(describing: MatchSummaryView.self), owner: self, options: nil)
        summaryView.frame = self.bounds
        summaryView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(summaryView)
    }

    // MARK: - Public Methods

    func resetView() {
        redContainerView.layer.borderWidth = 0.0
        blueContainerView.layer.borderWidth = 0.0

        redScoreLabel.font = notWinnerFont
        blueScoreLabel.font = notWinnerFont
    }

    // MARK: - Private Methods

    private func removeTeams() {
        for stackView in [redStackView, blueStackView] as [UIStackView] {
            for view in stackView.arrangedSubviews {
                if [redScoreLabel, blueScoreLabel].contains(view) {
                    continue
                }
                view.removeFromSuperview()
            }
        }
    }
    
    private func removeRPs() {
        for stackView in [redRPStackView, blueRPStackView] as [UIStackView] {
            for view in stackView.arrangedSubviews {
                view.removeFromSuperview()
            }
        }
    }

    private func configureView() {
        guard let viewModel = viewModel else {
            return
        }

        matchNumberLabel.text = viewModel.matchName
        playIconImageView.isHidden = viewModel.hasVideos

        removeTeams()
        removeRPs()

        for (alliance, stackView) in [(viewModel.redAlliance, redStackView!), (viewModel.blueAlliance, blueStackView!)] {
            for teamKey in alliance {
                let label = teamLabel(for: teamKey, baseTeamKey: viewModel.baseTeamKey, dq: viewModel.dqs.contains(teamKey))
                // Insert each new stack view at the index just before the score view
                stackView.insertArrangedSubview(label, at: stackView.arrangedSubviews.count - 1)
            }
        }

        // Add red RP to view
        addRPToView(stackView: redRPStackView, rpCount: viewModel.redRPCount)
        // Add blue RP to view
        addRPToView(stackView: blueRPStackView, rpCount: viewModel.blueRPCount)

        redScoreLabel.text = viewModel.redScore
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
    
    private func addRPToView(stackView: UIStackView, rpCount: Int) {
        for _ in 0..<rpCount {
            let rpLabel = label(text: "•", isBold: true)
            stackView.addArrangedSubview(rpLabel)
        }
    }
    
    private func teamLabel(for teamKey: String, baseTeamKey: String?, dq: Bool) -> UILabel {
        let text: String = "\(Team.trimFRCPrefix(teamKey))"
        let isBold: Bool = (teamKey == baseTeamKey)

        return label(text: text, isBold: isBold, isStrikethrough: dq)
    }

    private func label(text: String, isBold: Bool, isStrikethrough: Bool = false) -> UILabel {
        let attributeString =  NSMutableAttributedString(string: text)
        let attributedStringRange = NSMakeRange(0, attributeString.length)

        var font: UIFont = .systemFont(ofSize: 14)
        if isBold {
            font = .boldSystemFont(ofSize: 14)
        }
        attributeString.addAttribute(.font, value: font, range: attributedStringRange)

        if isStrikethrough {
            attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: attributedStringRange)
        }

        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = attributeString

        return label
    }

}
