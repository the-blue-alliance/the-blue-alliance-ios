import CoreData
import Foundation
import MyTBAKit
import TBAKit
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

        let maximumHeaderHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.autoSetDimension(.height, toSize: maximumHeaderHeight)

        // Hide our navigation title view
        navigationItem.titleView?.isHidden = true
    }

}
