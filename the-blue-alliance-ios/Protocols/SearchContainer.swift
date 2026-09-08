import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit

protocol SearchContainer: ContainerViewController {
    var searchController: UISearchController { get }
}

extension SearchContainer where Self: SearchViewControllerDelegate {

    func makeSearchController() -> UISearchController {
        let searchViewController = SearchViewController(dependencies: dependencies)
        searchViewController.delegate = self

        let searchController = UISearchController(searchResultsController: searchViewController)
        searchController.delegate = searchViewController

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.showsSearchResultsController = true
        searchController.searchResultsUpdater = searchViewController
        searchController.scopeBarActivation = .onSearchActivation

        // Style our search bar
        searchController.searchBar.backgroundColor = UIColor.navigationBarTintColor
        searchController.searchBar.autocapitalizationType = .words
        searchController.searchBar.scopeButtonTitles = SearchScope.allCases.map { $0.title }
        searchController.searchBar.delegate = searchViewController

        // Style our search bar text field
        searchController.searchBar.searchTextField.textColor = UIColor.white
        searchController.searchBar.searchTextField.tintColor = UIColor.white
        searchController.searchBar.searchTextField.leftView?.tintColor = UIColor.white
        searchController.searchBar.searchTextField.backgroundColor =
            UIColor.searchFieldBackgroundColor
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search teams and events",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )
        return searchController
    }

    func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

}

protocol SearchContainerDelegate {
    var dependencies: Dependencies { get }
}

extension SearchContainerDelegate where Self: ContainerViewController {

    func eventSelected(eventKey: EventKey, name: String?) {
        let eventViewController = EventViewController(
            eventKey: eventKey,
            name: name,
            dependencies: dependencies
        )
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    func teamSelected(teamKey: String, nickname: String?) {
        let teamViewController = TeamViewController(
            teamKey: teamKey,
            nickname: nickname,
            dependencies: dependencies
        )
        navigationController?.pushViewController(teamViewController, animated: true)
    }

    func teamSelected(_ team: any TeamDisplayable) {
        let teamViewController = TeamViewController(
            teamKey: team.key,
            nickname: team.nickname,
            dependencies: dependencies
        )
        navigationController?.pushViewController(teamViewController, animated: true)
    }

}
