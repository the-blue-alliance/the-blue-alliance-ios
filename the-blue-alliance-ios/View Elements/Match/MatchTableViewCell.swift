import Foundation
import UIKit

class MatchTableViewCell: UITableViewCell, Reusable {

    var viewModel: MatchViewModel? {
        didSet {
            matchSummaryView.viewModel = viewModel
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private var matchSummaryView: MatchSummaryView!

    private var coloredViews: [UIView] {
        return [matchSummaryView.redContainerView, matchSummaryView.redScoreLabel, matchSummaryView.blueContainerView, matchSummaryView.blueScoreLabel, matchSummaryView.timeView]
    }

    // MARK: - View Methods

    override func setSelected(_ selected: Bool, animated: Bool) {
        let colors = storeBaseColors(for: coloredViews)
        super.setSelected(selected, animated: animated)

        if selected {
            restoreBaseColors(colors, for: coloredViews)
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let colors = storeBaseColors(for: coloredViews)
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            restoreBaseColors(colors, for: coloredViews)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        matchSummaryView?.resetView()
    }

    // MARK: - Private Methods

    private func storeBaseColors(for views: [UIView]) -> [UIColor] {
        var colors: [UIColor] = []
        for view in views {
            colors.append(view.backgroundColor!)
        }
        return colors
    }

    private func restoreBaseColors(_ colors: [UIColor], for views: [UIView]) {
        if colors.count != views.count {
            return
        }

        for (index, view) in views.enumerated() {
            view.backgroundColor = colors[index]
        }
    }

}
