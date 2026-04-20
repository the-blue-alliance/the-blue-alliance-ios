import Foundation
import MyTBAKit
import UIKit

class HeaderContainerViewController: MyTBAContainerViewController {

    var headerView: UIView {
        fatalError("Implement headerView in a subclass")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeader()
    }

    // MARK: - Private Methods

    private func setupHeader() {
        rootStackView.insertArrangedSubview(headerView, at: 0)

        // Set our header view height to the height it would be at it's most compact
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let maximumHeaderHeight = headerView.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        ).height
        headerView.autoSetDimension(.height, toSize: maximumHeaderHeight)

        // Drop the two-line title view entirely; the header view is the title now.
        // Nil-ing (vs. hiding) also removes its stale zero-width layout constraints.
        navigationItem.titleView = nil
    }

}
