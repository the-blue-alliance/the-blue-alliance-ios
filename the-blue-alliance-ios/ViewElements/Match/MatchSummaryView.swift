import Foundation
import TBAAPI
import UIKit

protocol MatchSummaryViewDelegate: AnyObject {
    func teamPressed(teamKey: String)
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

    private let winnerFont = UIFontMetrics(forTextStyle: .body).scaledFont(
        for: UIFont.systemFont(ofSize: 14, weight: .bold)
    )
    private let notWinnerFont = UIFontMetrics(forTextStyle: .body).scaledFont(
        for: UIFont.systemFont(ofSize: 14, weight: .medium)
    )

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

    private var redAllianceLabel: UILabel!
    private var blueAllianceLabel: UILabel!
    private var redLeftVStack: UIStackView!
    private var blueLeftVStack: UIStackView!
    private var redScoreWidth: NSLayoutConstraint?
    private var blueScoreWidth: NSLayoutConstraint?

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
        Bundle.main.loadNibNamed(
            String(describing: MatchSummaryView.self),
            owner: self,
            options: nil
        )
        summaryView.frame = self.bounds
        summaryView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(summaryView)

        installAllianceLabels()
        styleInterface()
    }

    // Restructures each colored container into HStack[ VStack[ allianceLabel,
    // teamHStack ], scoreView ] — replacing the xib's flat layout so the score
    // can span the full container height while the alliance label sits over
    // the team row.
    private func installAllianceLabels() {
        for (container, teamHStack, scoreView, isRed) in [
            (redContainerView!, redStackView!, redScoreView!, true),
            (blueContainerView!, blueStackView!, blueScoreView!, false),
        ] {
            container.constraints
                .filter { $0.firstItem === teamHStack || $0.secondItem === teamHStack }
                .forEach { $0.isActive = false }
            teamHStack.removeFromSuperview()
            scoreView.removeFromSuperview()

            let allianceLabel = UILabel()
            allianceLabel.font = .boldSystemFont(ofSize: 11)
            allianceLabel.textColor = .label
            allianceLabel.numberOfLines = 1
            allianceLabel.lineBreakMode = .byTruncatingTail
            allianceLabel.adjustsFontForContentSizeCategory = true
            allianceLabel.isHidden = true

            let leftVStack = UIStackView(arrangedSubviews: [allianceLabel, teamHStack])
            leftVStack.axis = .vertical
            leftVStack.alignment = .fill
            leftVStack.distribution = .fill
            leftVStack.spacing = 2
            leftVStack.isLayoutMarginsRelativeArrangement = true
            leftVStack.directionalLayoutMargins = .init(
                top: 0,
                leading: 8,
                bottom: 0,
                trailing: 0
            )

            let rootHStack = UIStackView(arrangedSubviews: [leftVStack, scoreView])
            rootHStack.axis = .horizontal
            rootHStack.alignment = .fill
            rootHStack.distribution = .fill
            rootHStack.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(rootHStack)
            NSLayoutConstraint.activate([
                rootHStack.topAnchor.constraint(equalTo: container.topAnchor),
                rootHStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                rootHStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                rootHStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])

            if isRed {
                redAllianceLabel = allianceLabel
                redLeftVStack = leftVStack
            } else {
                blueAllianceLabel = allianceLabel
                blueLeftVStack = leftVStack
            }
        }
    }

    // Anchors the score view's width to the first team column so columns stay
    // equal regardless of whether the inline pill bumps the team stack from 3
    // to 4 entries. Re-installed after every configureView since the
    // arrangedSubviews array is rebuilt.
    private func updateScoreColumnWidth(
        scoreView: UIView,
        teamStack: UIStackView,
        existing: inout NSLayoutConstraint?
    ) {
        existing?.isActive = false
        guard let firstColumn = teamStack.arrangedSubviews.first else {
            existing = nil
            return
        }
        let constraint = scoreView.widthAnchor.constraint(equalTo: firstColumn.widthAnchor)
        constraint.isActive = true
        existing = constraint
    }

    private func styleInterface() {
        redContainerView.backgroundColor = UIColor.redAllianceBackgroundColor
        redScoreLabel.backgroundColor = UIColor.redAllianceScoreBackgroundColor
        redScoreLabel.adjustsFontForContentSizeCategory = true

        blueContainerView.backgroundColor = UIColor.blueAllianceBackgroundColor
        blueScoreLabel.backgroundColor = UIColor.blueAllianceScoreBackgroundColor
        blueScoreLabel.adjustsFontForContentSizeCategory = true
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

        matchNumberLabel.text = stackedMatchName(viewModel.matchName)
        playIconImageView.isHidden = !viewModel.hasVideos

        removeTeams()
        removeRPs()

        let baseTeamKeys = viewModel.baseTeamKeys
        let alliancePairs:
            [(
                alliance: [String], stackView: UIStackView, badge: AllianceLookup.Entry?,
                topLabel: UILabel, leftVStack: UIStackView, side: AllianceBadgeView.Side
            )] = [
                (
                    viewModel.redAlliance, redStackView!, viewModel.redAllianceBadge,
                    redAllianceLabel, redLeftVStack, .red
                ),
                (
                    viewModel.blueAlliance, blueStackView!, viewModel.blueAllianceBadge,
                    blueAllianceLabel, blueLeftVStack, .blue
                ),
            ]
        for (alliance, stackView, badge, topLabel, leftVStack, side) in alliancePairs {
            applyAllianceIdentifier(
                badge,
                to: topLabel,
                leftVStack: leftVStack,
                stackView: stackView,
                side: side
            )
            for teamKey in alliance {
                let dq = viewModel.dqs.contains(teamKey)
                let label =
                    teamsTappable
                    ? teamButton(for: teamKey, baseTeamKeys: baseTeamKeys, dq: dq)
                    : teamLabel(for: teamKey, baseTeamKeys: baseTeamKeys, dq: dq)
                stackView.addArrangedSubview(label)
            }
        }

        updateScoreColumnWidth(
            scoreView: redScoreView,
            teamStack: redStackView,
            existing: &redScoreWidth
        )
        updateScoreColumnWidth(
            scoreView: blueScoreView,
            teamStack: blueStackView,
            existing: &blueScoreWidth
        )

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

    // Wraps "Semis 1-1" → "Semis\n1-1" so wider playoff numbers don't shrink to
    // fit. Single-digit numbers stay inline; they fit comfortably as one line.
    private func stackedMatchName(_ name: String) -> String {
        guard let spaceIndex = name.lastIndex(of: " ") else { return name }
        let trailing = name[name.index(after: spaceIndex)...]
        guard trailing.count >= 2 else { return name }
        return name.replacingCharacters(in: spaceIndex...spaceIndex, with: "\n")
    }

    private func applyAllianceIdentifier(
        _ entry: AllianceLookup.Entry?,
        to label: UILabel,
        leftVStack: UIStackView,
        stackView: UIStackView,
        side: AllianceBadgeView.Side
    ) {
        guard let entry else {
            label.text = nil
            label.isHidden = true
            setAllianceLabelMargins(showing: false, on: leftVStack)
            return
        }

        // EITHER the top-row label OR the inline pill carries the identity, never both.
        if let name = entry.customName {
            label.text = name.uppercased()
            label.isHidden = false
            setAllianceLabelMargins(showing: true, on: leftVStack)
        } else {
            label.text = nil
            label.isHidden = true
            setAllianceLabelMargins(showing: false, on: leftVStack)
            let badge = AllianceBadgeView(number: entry.number, name: entry.name, side: side)
            stackView.insertArrangedSubview(badge, at: 0)
        }
    }

    private func setAllianceLabelMargins(showing: Bool, on stack: UIStackView) {
        let v: CGFloat = showing ? 4 : 0
        stack.directionalLayoutMargins = .init(top: v, leading: 8, bottom: v, trailing: 0)
    }

    private func addRPToView(stackView: UIStackView, rpCount: [Bool]?) {
        guard let rpList = rpCount else { return }
        for rpValue in rpList {
            let rpLabel = label(
                text: rpValue ? "•" : "◦",
                isBold: true,
                color: rpValue ? .label : .secondaryLabel
            )
            stackView.addArrangedSubview(rpLabel)
        }
    }

    private func teamLabel(for teamKey: String, baseTeamKeys: [String], dq: Bool) -> UILabel {
        let text: String = "\(teamKey.trimPrefix)"
        let isBold: Bool = baseTeamKeys.contains(teamKey)

        return label(text: text, isBold: isBold, isStrikethrough: dq)
    }

    private func teamButton(for teamKey: String, baseTeamKeys: [String], dq: Bool) -> UIButton {
        let text: String = "\(teamKey.trimPrefix)"
        let isBold: Bool = baseTeamKeys.contains(teamKey)

        return button(text: text, teamKey: teamKey, isBold: isBold, isStrikethrough: dq)
    }

    private func button(text: String, teamKey: String, isBold: Bool, isStrikethrough: Bool = false)
        -> UIButton
    {
        let button = UIButton(type: .system)
        button.setTitle(text, for: [])
        button.setTitleColor(UIColor.highlightColor, for: .normal)

        button.titleLabel?.attributedText = customAttributedString(
            text: text,
            isBold: isBold,
            isStrikethrough: isStrikethrough
        )

        button.addAction(
            UIAction { [weak self] _ in
                self?.delegate?.teamPressed(teamKey: teamKey)
            },
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func label(
        text: String,
        isBold: Bool,
        isStrikethrough: Bool = false,
        color: UIColor = .label
    ) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = customAttributedString(
            text: text,
            isBold: isBold,
            isStrikethrough: isStrikethrough
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = color
        return label
    }

    private func customAttributedString(text: String, isBold: Bool, isStrikethrough: Bool = false)
        -> NSMutableAttributedString
    {
        let attributeString = NSMutableAttributedString(string: text)
        let attributedStringRange = NSMakeRange(0, attributeString.length)

        var font: UIFont = .systemFont(ofSize: 14)
        if isBold {
            font = .boldSystemFont(ofSize: 14)
        }
        attributeString.addAttribute(.font, value: font, range: attributedStringRange)

        if isStrikethrough {
            attributeString.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: attributedStringRange
            )
        }

        return attributeString
    }

}
