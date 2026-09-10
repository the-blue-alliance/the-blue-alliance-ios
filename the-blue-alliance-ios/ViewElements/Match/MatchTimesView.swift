import PureLayout
import UIKit

class MatchTimesView: UIView {

    var viewModel: MatchTimesViewModel? {
        didSet {
            configureView()
        }
    }

    let timeZoneSwitch = UISwitch()

    private static let rowFont = UIFontMetrics(forTextStyle: .body).scaledFont(
        for: UIFont.systemFont(ofSize: 14)
    )
    private static let valueFont = UIFontMetrics(forTextStyle: .body).scaledFont(
        for: UIFont.systemFont(ofSize: 14, weight: .medium)
    )

    private let headerLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.text = "Match Times"
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: UIFont.systemFont(ofSize: 16, weight: .medium)
        )
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var headerView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerLabel])
        stackView.backgroundColor = UIColor.systemFill
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    private let rowsStackView: UIStackView = {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private lazy var timeZoneRow: UIStackView = {
        let label = UILabel(forAutoLayout: ())
        label.text = "Show in my timezone"
        label.font = Self.rowFont
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        let stackView = UIStackView(arrangedSubviews: [label, Self.spacerView(), timeZoneSwitch])
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        let contentStackView = UIStackView(arrangedSubviews: [rowsStackView, timeZoneRow])
        contentStackView.axis = .vertical
        contentStackView.spacing = 8
        contentStackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        contentStackView.isLayoutMarginsRelativeArrangement = true

        let stackView = UIStackView(arrangedSubviews: [headerView, contentStackView])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()

        headerView.autoSetDimension(.height, toSize: 30)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func configureView() {
        for view in rowsStackView.arrangedSubviews {
            rowsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        guard let viewModel else { return }

        for row in viewModel.rows {
            rowsStackView.addArrangedSubview(Self.rowView(for: row))
        }
        timeZoneRow.isHidden = !viewModel.canToggleTimeZone
    }

    private static func rowView(for row: MatchTimesViewModel.Row) -> UIView {
        let titleLabel = UILabel(forAutoLayout: ())
        titleLabel.text = row.title
        titleLabel.font = rowFont
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = UIColor.secondaryLabel

        let valueLabel = UILabel(forAutoLayout: ())
        valueLabel.text = row.value
        valueLabel.font = valueFont
        valueLabel.adjustsFontForContentSizeCategory = true

        var trailingLabels: [UILabel] = []
        if let detail = row.detail {
            let detailLabel = UILabel(forAutoLayout: ())
            detailLabel.text = "(\(detail))"
            detailLabel.font = rowFont
            detailLabel.adjustsFontForContentSizeCategory = true
            detailLabel.textColor = UIColor.secondaryLabel
            trailingLabels.append(detailLabel)
        }
        trailingLabels.append(valueLabel)

        for label in [titleLabel] + trailingLabels {
            label.setContentHuggingPriority(.required, for: .horizontal)
        }

        let stackView = UIStackView(
            arrangedSubviews: [titleLabel, spacerView()] + trailingLabels
        )
        stackView.spacing = 4
        return stackView
    }

    // Low compression resistance so the gap closes before a label truncates.
    private static func spacerView() -> UIView {
        let spacer = UIView(forAutoLayout: ())
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return spacer
    }

}
