import PureLayout
import UIKit

nonisolated struct DashboardTile: Hashable {
    enum Style: Hashable {
        case blue
        case yellow
    }

    let title: String
    let actionTitle: String
    let style: Style
    let tab: RootType
}

/// Side-by-side tinted shortcut tiles that sit directly on the page rather than inside a card.
class DashboardTilesTableViewCell: UITableViewCell, Reusable {

    var tiles: [DashboardTile] = [] {
        didSet { configureCell() }
    }

    var tileTapped: ((DashboardTile) -> Void)?

    private let stackView: UIStackView = {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundConfiguration = .clear()
        selectionStyle = .none

        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tileTapped = nil
    }

    private func configureCell() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        for tile in tiles {
            let view = DashboardTileView(tile: tile)
            view.addAction(
                UIAction { [weak self] _ in self?.tileTapped?(tile) },
                for: .touchUpInside
            )
            stackView.addArrangedSubview(view)
        }
    }

}

private class DashboardTileView: UIControl {

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1 }
    }

    init(tile: DashboardTile) {
        super.init(frame: .zero)

        layer.cornerRadius = 14
        layer.cornerCurve = .continuous
        backgroundColor =
            switch tile.style {
            case .blue: UIColor.primaryBlue.withAlphaComponent(0.14)
            case .yellow: UIColor.systemYellow.withAlphaComponent(0.2)
            }

        let titleLabel = UILabel(forAutoLayout: ())
        titleLabel.text = tile.title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        let actionLabel = UILabel(forAutoLayout: ())
        actionLabel.text = "\(tile.actionTitle) →"
        let base = UIFont.preferredFont(forTextStyle: .subheadline)
        actionLabel.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(
            for: .systemFont(ofSize: base.pointSize, weight: .semibold)
        )
        actionLabel.adjustsFontForContentSizeCategory = true
        actionLabel.textColor = .highlightColor

        let spacer = UIView(forAutoLayout: ())
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, spacer, actionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isUserInteractionEnabled = false

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(
            with: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        )

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "\(tile.title), \(tile.actionTitle)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
