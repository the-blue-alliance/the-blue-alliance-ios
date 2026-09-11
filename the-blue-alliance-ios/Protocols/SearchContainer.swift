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

        searchController.searchBar.autocapitalizationType = .words
        searchController.searchBar.scopeButtonTitles = SearchScope.allCases.map { $0.title }
        searchController.searchBar.delegate = searchViewController

        return searchController
    }

    func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        view.backgroundColor = UIColor.systemGroupedBackground

        // Adopting the search bar resets its text field to UIKit's own appearance, so the
        // colors only stick when they go on after the hand-off.
        let searchBar = searchController.searchBar
        searchBar.searchTextField.textColor = UIColor.white
        searchBar.searchTextField.tintColor = UIColor.white
        searchBar.searchTextField.leftView?.tintColor = UIColor.white
        searchBar.searchTextField.backgroundColor = UIColor.searchFieldBackgroundColor
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search teams and events",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )
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

    // The results controller is laid out below the search bar rather than flush against it, so
    // the container's own list would otherwise show through the band between the two.
    func searchWillPresent() {
        rootStackView.isHidden = true
    }

    func searchWillDismiss() {
        rootStackView.isHidden = false
    }

}
