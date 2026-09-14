import Foundation
import MyTBAKit
import UIKit
import TBAAuth

class MyTBAContainerViewController: ContainerViewController, Subscribable {

    lazy var favoriteBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage.starIcon,
            primaryAction: UIAction { [weak self] _ in self?.presentMyTBAPreferences() }
        )
    }()

    var subscribableModel: any MyTBASubscribable {
        fatalError("Implement subscribableModel in subclass")
    }

    // MARK: - Init

    override init(
        viewControllers: [any ContainableViewController],
        navigationTitle: String? = nil,
        navigationSubtitle: String? = nil,
        segmentedControlTitles: [String]? = nil,
        dependencies: Dependencies
    ) {

        super.init(
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

    // MARK: - Navigation Item

    override var currentRightBarButtonItems: [UIBarButtonItem] {
        rightBarButtonItems + (dependencies.authService.isSignedIn ? [favoriteBarButtonItem] : [])
    }

}
