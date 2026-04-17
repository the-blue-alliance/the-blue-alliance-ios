import Foundation
import MyTBAKit
import Photos
import TBAAPI
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
        searchController.scopeBarActivation = .onSearchActivation

        navigationItem.searchController = searchController

        // Style our search bar
        searchController.searchBar.backgroundColor = UIColor.navigationBarTintColor
        searchController.searchBar.autocapitalizationType = .words
        searchController.searchBar.scopeButtonTitles = SearchScope.allCases.map { $0.title }
        searchController.searchBar.delegate = searchViewController

        // Style our search bar text field
        searchController.searchBar.searchTextField.textColor = UIColor.white
        searchController.searchBar.searchTextField.tintColor = UIColor.white
        searchController.searchBar.searchTextField.leftView?.tintColor = UIColor.white
        searchController.searchBar.searchTextField.backgroundColor = UIColor.searchFieldBackgroundColor
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search teams and events",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )

        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true
    }

}

protocol SearchContainerDelegate {
    var dependencies: Dependencies { get }
}

extension SearchContainerDelegate where Self: ContainerViewController {

    func eventSelected(eventKey: String, name: String?) {
        let eventViewController = EventViewController(eventKey: eventKey, name: name, dependencies: dependencies)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    func teamSelected(teamKey: String, nickname: String?) {
        let teamViewController = TeamViewController(teamKey: teamKey, nickname: nickname, dependencies: dependencies)
        navigationController?.pushViewController(teamViewController, animated: true)
    }

    func teamSelected(_ team: Team) {
        let teamViewController = TeamViewController(team: team, dependencies: dependencies)
        navigationController?.pushViewController(teamViewController, animated: true)
    }

}
