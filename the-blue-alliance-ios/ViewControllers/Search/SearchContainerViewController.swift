import Foundation
import UIKit
import PureLayout

class SearchContainerViewController: ContainerViewController {

    private let searchViewController: SearchViewController

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = searchViewController
        searchController.delegate = searchViewController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search teams and events"
        searchController.searchBar.autocapitalizationType = .words
        return searchController
    }()

    init(dependencies: Dependencies) {
        searchViewController = SearchViewController(dependencies: dependencies)

        super.init(
            viewControllers: [searchViewController],
            segmentedControlTitles: SearchScope.allCases.map { $0.title },
            dependencies: dependencies
        )

        // Search has no title of its own, so screens pushed from it get a bare chevron.
        navigationItem.backButtonDisplayMode = .minimal
        tabBarItem.image = RootType.search.icon

        searchViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // Search has no title and its field sits in the tab bar, so the navigation bar would only be
    // an empty band. Hiding it before the tab shows keeps search activation from collapsing it.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // The segmented control filters the one child rather than switching between children.
    override func switchedToIndex(_ index: Int) {
        guard index < SearchScope.allCases.count else { return }
        searchViewController.scope = SearchScope.allCases[index]
    }

}

extension SearchContainerViewController: SearchContainerDelegate, SearchViewControllerDelegate {}
