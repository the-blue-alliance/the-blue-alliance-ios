import Foundation
import UIKit

class EventStatsView: UIView, Reusable {

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
        let label = EventStatsView.label()
        label.textAlignment = .center
        label.textColor = UIColor.secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        return label
    }()
    fileprivate lazy var leftLabel: UILabel = {
        let label = EventStatsView.label()
        label.textAlignment = .left
        label.textColor = UIColor.label
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    fileprivate lazy var rightLabel: UILabel = {
        let label = EventStatsView.label()
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

class EventStatsHeaderView: UITableViewHeaderFooterView, Reusable {

    private lazy var eventStatsView = EventStatsView()

    var title: String? {
        didSet {
            eventStatsView.title = title
        }
    }
    var leftTitle: String? {
        didSet {
            eventStatsView.leftTitle = leftTitle
        }
    }
    var rightTitle: String? {
        didSet {
            eventStatsView.rightTitle = rightTitle
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        eventStatsView.titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        eventStatsView.titleLabel.font = UIFont.systemFont(ofSize: eventStatsView.titleLabel.font.pointSize, weight: .semibold)
        eventStatsView.leftLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        eventStatsView.rightLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)

        eventStatsView.titleLabel.textColor = UIColor.white
        eventStatsView.leftLabel.textColor = UIColor.white
        eventStatsView.rightLabel.textColor = UIColor.white

        contentView.addSubview(eventStatsView)
        contentView.backgroundColor = UIColor.tableViewHeaderColor

        eventStatsView.autoPinEdgesToSuperviewSafeArea()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class EventStatsTableViewCell: UITableViewCell, Reusable {

    private lazy var eventStatsView = EventStatsView()

    var title: String? {
        didSet {
            eventStatsView.title = title
        }
    }
    var leftTitle: String? {
        didSet {
            eventStatsView.leftTitle = leftTitle
        }
    }
    var rightTitle: String? {
        didSet {
            eventStatsView.rightTitle = rightTitle
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(eventStatsView)
        eventStatsView.autoPinEdgesToSuperviewEdges()
        eventStatsView.autoSetDimension(.height, toSize: 44, relation: .greaterThanOrEqual)

        // separatorInset = .zero
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
