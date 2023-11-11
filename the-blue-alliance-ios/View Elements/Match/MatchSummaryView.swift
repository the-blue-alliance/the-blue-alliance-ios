import Foundation
import TBAData
import UIKit

protocol MatchSummaryViewDelegate: AnyObject {
    func teamPressed(teamNumber: Int)
}

class MatchSummaryView: UIView {
    
    public weak var delegate: MatchSummaryViewDelegate?
    
    var viewModel: MatchViewModel? {
        didSet {
            configureView()
        }
    }
    
    // change this variable so that the teams are shown as buttons
    private var teamsTappable: Bool = false

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
            redContainerView.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
    @IBOutlet weak var redScoreView: UIView!
    @IBOutlet weak var redScoreLabel: UILabel!
    @IBOutlet private weak var redRPStackView: UIStackView!

    @IBOutlet weak private var blueStackView: UIStackView!
    @IBOutlet weak var blueContainerView: UIView! {
        didSet {
            blueContainerView.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    @IBOutlet weak var blueScoreView: UIView!
    @IBOutlet weak var blueScoreLabel: UILabel!
    @IBOutlet private weak var blueRPStackView: UIStackView!

    @IBOutlet weak var timeLabel: UILabel!
    

    // MARK: - Init

    init(teamsTappable: Bool = false) {
        super.init(frame: .zero)
        
        self.teamsTappable = teamsTappable
        initMatchView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initMatchView()
    }

    private func initMatchView() {
        Bundle.main.loadNibNamed(String(describing: MatchSummaryView.self), owner: self, options: nil)
        summaryView.frame = self.bounds
        summaryView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(summaryView)

        styleInterface()
    }

    private func styleInterface() {
        redContainerView.backgroundColor = UIColor.redAllianceBackgroundColor
        redScoreLabel.backgroundColor = UIColor.redAllianceScoreBackgroundColor

        blueContainerView.backgroundColor = UIColor.blueAllianceBackgroundColor
        blueScoreLabel.backgroundColor = UIColor.blueAllianceScoreBackgroundColor
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
                if [redScoreView, blueScoreView].contains(view) {
                    continue
                }
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
    }
    
    private func removeRPs() {
        for stackView in [redRPStackView, blueRPStackView] as [UIStackView] {
            for view in stackView.arrangedSubviews {
                stackView.removeArrangedSubview(view)
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

        let baseTeamKeys = viewModel.baseTeamKeys
        for (alliance, stackView) in [(viewModel.redAlliance, redStackView!), (viewModel.blueAlliance, blueStackView!)] {
            for teamKey in alliance {
                let dq = viewModel.dqs.contains(teamKey)
                // if teams are tappable, load the team #s as buttons to link to the team page
                let label = teamsTappable
                    ? teamButton(for: teamKey, baseTeamKeys: baseTeamKeys, dq: dq)
                    : teamLabel(for: teamKey, baseTeamKeys: baseTeamKeys, dq: dq)
                // Insert each new stack view at the index just before the score view
                stackView.insertArrangedSubview(label, at: stackView.arrangedSubviews.count - 1)
            }
        }

        // Add red RP to view
        addRPToView(stackView: redRPStackView, rpCount: viewModel.redRPCount)
        // Add blue RP to view
        addRPToView(stackView: blueRPStackView, rpCount: viewModel.blueRPCount)

        if let redScore = viewModel.redScore {
            redScoreLabel.text = "\(redScore)"
        } else {
            redScoreLabel.text = nil
        }
        redScoreView.isHidden = viewModel.redScore == nil

        if let blueScore = viewModel.blueScore {
            blueScoreLabel.text = "\(blueScore)"
        } else {
            blueScoreLabel.text = nil
        }
        blueScoreView.isHidden = viewModel.blueScore == nil

        timeLabel.text = viewModel.timeString
        timeLabel.isHidden = viewModel.hasScores

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
    
    private func teamLabel(for teamKey: String, baseTeamKeys: [String], dq: Bool) -> UILabel {
        let text: String = "\(Team.trimFRCPrefix(teamKey))"
        let isBold: Bool = baseTeamKeys.contains(teamKey)

        return label(text: text, isBold: isBold, isStrikethrough: dq)
    }
    
    private func teamButton(for teamKey: String, baseTeamKeys: [String], dq: Bool) -> UIButton {
        let text: String = "\(Team.trimFRCPrefix(teamKey))"
        let isBold: Bool = baseTeamKeys.contains(teamKey)

        return button(text: text, isBold: isBold, isStrikethrough: dq)
    }
    
    private func button(text: String, isBold: Bool, isStrikethrough: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: [])
        button.setTitleColor(UIColor.highlightColor, for: .normal)
        
        if let teamNumber = Int(text) {
            button.tag = teamNumber
        }

        button.titleLabel?.attributedText = customAttributedString(text: text, isBold: isBold, isStrikethrough: isStrikethrough)

        button.addTarget(self, action: #selector(teamPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func label(text: String, isBold: Bool, isStrikethrough: Bool = false) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = customAttributedString(text: text, isBold: isBold, isStrikethrough: isStrikethrough)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.label
        return label
    }
    
    @objc private func teamPressed(sender: UIButton) {
        if sender.tag == 0 { return }
        delegate?.teamPressed(teamNumber: sender.tag)
    }
    
    private func customAttributedString(text: String, isBold: Bool, isStrikethrough: Bool = false) -> NSMutableAttributedString {
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
        
        return attributeString
    }

}
