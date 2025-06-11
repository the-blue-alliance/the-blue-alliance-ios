import Foundation
import TBAAPI
import UIKit

let kNoSelectionNavigationController = "NoSelectionNavigationController"

class PadRootViewController: UISplitViewController, RootController {

    weak var dependencyProvider: DependencyProvider!

    lazy var emptyNavigationController: UINavigationController = {
       guard let emptyViewController = Bundle.main.loadNibNamed("EmptyViewController", owner: nil, options: nil)?.first as? UIViewController else {
           fatalError("Unable to load empty view controller")
        }

        let navigationController = UINavigationController(rootViewController: emptyViewController)
        navigationController.restorationIdentifier = kNoSelectionNavigationController

        return navigationController
    }()

    init(dependencyProvider: DependencyProvider) {
        self.dependencyProvider = dependencyProvider

        super.init(nibName: nil, bundle: nil)

        let masterNavigationController = UINavigationController(rootViewController: PadMasterViewController(dependencyProvider: dependencyProvider))
        viewControllers = [masterNavigationController, emptyNavigationController]

        preferredDisplayMode = .oneBesideSecondary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// TODO: Oh - this is a search container... isn't it
private class PadMasterViewController: TBACollectionViewListController<UICollectionViewListCell, RootType>, RootController {

    // var searchController: UISearchController!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // setupSearchController()
    }

    // MARK: - RootController

    func _push(_ viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        showDetailViewController(navigationController, sender: nil)
    }

}
