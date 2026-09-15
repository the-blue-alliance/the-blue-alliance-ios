import Foundation
import MyTBAKit
import UIKit
import TBAAuth

class MyTBAContainerViewController: ContainerViewController, Subscribable {

    lazy var favoriteBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage.starOutlineIcon,
            primaryAction: UIAction { [weak self] _ in self?.presentMyTBAPreferences() }
        )
    }()

    let subscribableModel: any MyTBASubscribable

    // MARK: - Init

    init(
        subscribableModel: any MyTBASubscribable,
        viewControllers: [any ContainableViewController],
        navigationTitle: String? = nil,
        navigationSubtitle: String? = nil,
        segmentedControlTitles: [String]? = nil,
        dependencies: Dependencies
    ) {
        self.subscribableModel = subscribableModel

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

    // Reading the favorites store here re-runs this when a favorite is saved or removed.
    override func updateProperties() {
        super.updateProperties()

        let isFavorite = dependencies.myTBAStores.favorites.favorites.contains {
            $0.modelKey == subscribableModel.modelKey && $0.modelType == subscribableModel.modelType
        }
        favoriteBarButtonItem.image = isFavorite ? UIImage.starIcon : UIImage.starOutlineIcon
    }

}
