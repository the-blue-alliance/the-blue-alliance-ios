import Foundation
import MyTBAKit
import Photos
import UIKit

protocol SearchContainer: ContainerViewController {
    var searchController: UISearchController! { get set }
}

extension SearchContainer where Self: SearchViewControllerDelegate {

    func setupSearchController() {
        let searchViewController = SearchViewController(dependencies: dependencies)
        searchViewController.delegate = self

        searchController = UISearchController(searchResultsController: searchViewController)
        searchController.delegate = searchViewController

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.showsSearchResultsController = true
        searchController.searchResultsUpdater = searchViewController

        navigationItem.searchController = searchController

        // Style our search bar
        searchController.searchBar.backgroundColor = UIColor.navigationBarTintColor
        searchController.searchBar.autocapitalizationType = .words
        searchController.searchBar.placeholder = "Search teams and events"
        searchController.searchBar.scopeButtonTitles = SearchScope.allCases.map { $0.title }
        searchController.searchBar.delegate = searchViewController

        // Style our search bar text field
        searchController.searchBar.searchTextField.textColor = UIColor.white
        searchController.searchBar.searchTextField.tintColor = UIColor.white
        searchController.searchBar.searchTextField.leftView?.tintColor = UIColor.white
        searchController.searchBar.searchTextField.backgroundColor = UIColor.tableViewHeaderColor

        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true
    }

}

protocol SearchContainerDelegate {
    var dependencies: Dependencies { get }
}

extension SearchContainerDelegate where Self: ContainerViewController {

    func eventSelected(eventKey: String) {
        let eventViewController = EventViewController(eventKey: eventKey, dependencies: dependencies)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    func teamSelected(teamKey: String) {
        let teamViewController = TeamViewController(teamKey: teamKey, dependencies: dependencies)
        navigationController?.pushViewController(teamViewController, animated: true)
    }

}
