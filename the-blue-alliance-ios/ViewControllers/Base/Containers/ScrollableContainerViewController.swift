import Foundation
import MyTBAKit
import UIKit
import PureLayout

class HeaderContainerViewController: MyTBAContainerViewController {

    let headerView: UIView

    // MARK: - Init

    init(
        headerView: UIView,
        subscribableModel: any MyTBASubscribable,
        viewControllers: [any ContainableViewController],
        navigationTitle: String? = nil,
        navigationSubtitle: String? = nil,
        segmentedControlTitles: [String]? = nil,
        dependencies: Dependencies
    ) {
        self.headerView = headerView

        super.init(
            subscribableModel: subscribableModel,
            viewControllers: viewControllers,
            navigationTitle: navigationTitle,
            navigationSubtitle: navigationSubtitle,
            segmentedControlTitles: segmentedControlTitles,
            dependencies: dependencies
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
