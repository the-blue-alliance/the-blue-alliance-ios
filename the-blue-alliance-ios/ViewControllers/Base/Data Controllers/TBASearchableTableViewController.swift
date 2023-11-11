import Foundation
import UIKit

protocol SearchableController {
    func updateDataSource()
}

class TBASearchableTableViewController: TBATableViewController, SearchableController {

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.tabBarTintColor
        return searchController
    }()

    // MARK: - Public Methods

    public func setupSearch() {
        tableView.tableHeaderView = searchController.searchBar
        tableView.backgroundView = UIView() // Hack to fix white background when refreshing in dark mode

        // Used to make sure the UISearchBar stays in our root VC (this VC) when presented and doesn't overlay in push
        definesPresentationContext = true
    }

    // MARK: - Table View Delegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let text = searchController.searchBar.text, text.isEmpty, searchController.isActive {
            searchController.isActive = false
        }
    }

    // MARK: - SearchableController

    func updateDataSource() {
        fatalError("Implement updateDataSource in subclass")
    }

}

extension TBASearchableTableViewController: UISearchResultsUpdating {

    public func updateSearchResults(for searchController: UISearchController) {
        OperationQueue.main.addOperation {
            self.updateDataSource()
        }
    }

}
