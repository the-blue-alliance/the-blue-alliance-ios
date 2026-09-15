import PureLayout
import UIKit

nonisolated struct DashboardUpNextViewModel: Hashable {
    let month: String
    let day: String
    let name: String
    let detail: String?
    let relative: String?
}

/// An upcoming event: a calendar-style date tile, the event, and how far off it is.
class DashboardUpNextTableViewCell: UITableViewCell, Reusable {

    var viewModel: DashboardUpNextViewModel? {
        didSet { configureCell() }
    }

    private let dateTile: UIView = {
        let view = UIView(forAutoLayout: ())
        view.backgroundColor = .tertiarySystemFill
        view.layer.cornerRadius = 8
        return view
    }()

    private let monthLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let dayLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        let base = UIFont.preferredFont(forTextStyle: .title2)
        label.font = .systemFont(ofSize: base.pointSize, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()

    private let relativeLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .highlightColor
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator

        let dateStack = UIStackView(arrangedSubviews: [monthLabel, dayLabel])
        dateStack.axis = .vertical
        dateStack.alignment = .center
        dateStack.spacing = 0
        dateTile.addSubview(dateStack)
        dateStack.autoPinEdgesToSuperviewEdges(
            with: UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
        )
        dateTile.autoSetDimension(.width, toSize: 52)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel, relativeLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let rootStack = UIStackView(arrangedSubviews: [dateTile, textStack])
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.axis = .horizontal
        rootStack.alignment = .center
        rootStack.spacing = 12

        contentView.addSubview(rootStack)
        rootStack.autoPinEdgesToSuperviewMargins()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCell() {
        guard let viewModel else { return }
        monthLabel.text = viewModel.month.uppercased()
        dayLabel.text = viewModel.day
        nameLabel.text = viewModel.name
        detailLabel.text = viewModel.detail
        detailLabel.isHidden = viewModel.detail == nil
        relativeLabel.text = viewModel.relative
        relativeLabel.isHidden = viewModel.relative == nil
    }

}
