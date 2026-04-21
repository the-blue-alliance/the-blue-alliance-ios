import Foundation
import UIKit

class EventInsightsView: UIView, Reusable {

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var leftTitle: String? {
        didSet {
            leftLabel.text = leftTitle
        }
    }
    var rightTitle: String? {
        didSet {
            rightLabel.text = rightTitle
        }
    }

    fileprivate lazy var titleLabel: UILabel = {
        let label = EventInsightsView.label()
        label.textAlignment = .center
        label.textColor = UIColor.secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        return label
    }()
    fileprivate lazy var leftLabel: UILabel = {
        let label = EventInsightsView.label()
        label.textAlignment = .left
        label.textColor = UIColor.label
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    fileprivate lazy var rightLabel: UILabel = {
        let label = EventInsightsView.label()
        label.textAlignment = .right
        label.textColor = UIColor.label
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leftLabel, titleLabel, rightLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()

    init() {
        super.init(frame: .zero)

        preservesSuperviewLayoutMargins = true

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewMargins()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func label() -> UILabel {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        return label
    }

}

class EventInsightsHeaderView: UITableViewHeaderFooterView, Reusable {

    private lazy var eventInsightsView = EventInsightsView()

    var title: String? {
        didSet {
            eventInsightsView.title = title
        }
    }
    var leftTitle: String? {
        didSet {
            eventInsightsView.leftTitle = leftTitle
        }
    }
    var rightTitle: String? {
        didSet {
            eventInsightsView.rightTitle = rightTitle
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        eventInsightsView.titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        eventInsightsView.titleLabel.font = UIFont.systemFont(
            ofSize: eventInsightsView.titleLabel.font.pointSize,
            weight: .semibold
        )
        eventInsightsView.leftLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        eventInsightsView.rightLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)

        eventInsightsView.titleLabel.textColor = UIColor.white
        eventInsightsView.leftLabel.textColor = UIColor.white
        eventInsightsView.rightLabel.textColor = UIColor.white

        contentView.addSubview(eventInsightsView)
        contentView.backgroundColor = UIColor.tableViewHeaderColor

        eventInsightsView.autoPinEdgesToSuperviewSafeArea()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class FourColumnTableViewCell: UITableViewCell, Reusable {

    private let titleLabel = UILabel()
    private let playoffLabel = UILabel()
    private let qualLabel = UILabel()
    private let playoffValueLabels: [UILabel] = (0..<3).map { _ in UILabel() }
    private let qualsValueLabels: [UILabel] = (0..<3).map { _ in UILabel() }

    var title: String? {
        didSet { titleLabel.text = title }
    }

    var qualValues: [String] = [] {
        didSet {
            let labels = qualsValueLabels
            for (i, label) in labels.enumerated() {
                label.text = i < qualValues.count ? qualValues[i] : ""
            }
        }
    }
    var playoffValues: [String] = [] {
        didSet {
            let labels = playoffValueLabels
            for (i, label) in labels.enumerated() {
                label.text = i < playoffValues.count ? playoffValues[i] : ""
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let qualsView = UIStackView()
        let playoffsView = UIStackView()

        qualsView.axis = .horizontal
        qualsView.distribution = .fillEqually
        playoffsView.axis = .horizontal
        playoffsView.distribution = .fillEqually

        titleLabel.textColor = UIColor.secondaryLabel
        qualLabel.textColor = UIColor.tertiaryLabel
        playoffLabel.textColor = UIColor.tertiaryLabel

        qualsView.addArrangedSubview(qualLabel)
        playoffsView.addArrangedSubview(playoffLabel)
        qualsValueLabels.forEach {
            $0.textAlignment = .center
            qualsView.addArrangedSubview($0)
        }
        playoffValueLabels.forEach {
            $0.textAlignment = .center
            playoffsView.addArrangedSubview($0)
        }

        qualLabel.text = "Quals"
        playoffLabel.text = "Playoffs"

        let vertical = UIStackView(arrangedSubviews: [titleLabel, qualsView, playoffsView])
        vertical.axis = .vertical
        vertical.spacing = 4

        contentView.addSubview(vertical)
        vertical.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            vertical.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            vertical.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            vertical.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            vertical.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EventInsightsTableViewCell: UITableViewCell, Reusable {

    private lazy var eventInsightsView = EventInsightsView()

    var title: String? {
        didSet {
            eventInsightsView.title = title
        }
    }
    var leftTitle: String? {
        didSet {
            eventInsightsView.leftTitle = leftTitle
        }
    }
    var rightTitle: String? {
        didSet {
            eventInsightsView.rightTitle = rightTitle
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(eventInsightsView)
        eventInsightsView.autoPinEdgesToSuperviewEdges()
        eventInsightsView.autoSetDimension(.height, toSize: 44, relation: .greaterThanOrEqual)

        // separatorInset = .zero
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
