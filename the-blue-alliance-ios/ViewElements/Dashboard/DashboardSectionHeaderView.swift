import PureLayout
import UIKit

/// A large sentence-case section title, in place of the grouped table's small uppercase header.
class DashboardSectionHeaderView: UITableViewHeaderFooterView, Reusable {

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    private let titleLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        let base = UIFont.preferredFont(forTextStyle: .title2)
        label.font = UIFontMetrics(forTextStyle: .title2).scaledFont(
            for: .systemFont(ofSize: base.pointSize, weight: .bold)
        )
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        backgroundConfiguration = .clear()

        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewMargins(
            with: UIEdgeInsets(top: 18, left: 0, bottom: 4, right: 0)
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
