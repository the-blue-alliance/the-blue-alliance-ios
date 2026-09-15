import UIKit

/// The one row style inside Dashboard cards: a title with either a subtitle beneath it or a bold
/// value on the trailing edge, and a chevron when the row goes somewhere.
class DashboardListTableViewCell: UITableViewCell, Reusable {

    func configure(_ row: DashboardRow) {
        var content: UIListContentConfiguration =
            row.subtitle == nil ? .valueCell() : .subtitleCell()
        content.text = row.title
        if row.isEmphasized {
            content.textProperties.font = Self.semiboldFont(.body)
        }
        if let subtitle = row.subtitle {
            content.secondaryText = subtitle
            content.secondaryTextProperties.color = .secondaryLabel
        } else {
            content.secondaryText = row.value
            content.secondaryTextProperties.font = Self.semiboldFont(.body)
            content.secondaryTextProperties.color = .label
        }
        contentConfiguration = content

        accessoryType = row.action == nil ? .none : .disclosureIndicator
        selectionStyle = row.action == nil ? .none : .default
    }

    private static func semiboldFont(_ style: UIFont.TextStyle) -> UIFont {
        let base = UIFont.preferredFont(forTextStyle: style)
        return UIFontMetrics(forTextStyle: style).scaledFont(
            for: .systemFont(ofSize: base.pointSize, weight: .semibold)
        )
    }

}
