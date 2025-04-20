import Foundation
import MyTBAKit
import Photos
import TBAData
import UIKit

protocol SearchContainer: ContainerViewController {
    var searchService: SearchService { get }
    var searchController: UISearchController! { get set }
}

extension SearchContainer where Self: SearchViewControllerDelegate {

    func setupSearchController() {
        let searchViewController = SearchViewController(searchService: searchService, dependencies: dependencies)
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
        searchController.searchBar.placeholder = "Search events and teams"
        searchController.searchBar.scopeButtonTitles = SearchScope.allCases.map { $0.rawValue.capitalized }
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
    var myTBA: MyTBA { get }
    var pasteboard: UIPasteboard? { get }
    var photoLibrary: PHPhotoLibrary? { get }
    var statusService: StatusService { get }
    var urlOpener: URLOpener { get }
}

extension SearchContainerDelegate where Self: ContainerViewController {

    func eventSelected(_ event: Event) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let eventViewController = EventViewController(event: event, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        if let splitViewController = splitViewController {
            let navigationController = UINavigationController(rootViewController: eventViewController)
            splitViewController.showDetailViewController(navigationController, sender: nil)
        } else if let navigationController = navigationController {
            navigationController.pushViewController(eventViewController, animated: true)
        }
    }

    func teamSelected(_ team: Team) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let teamViewController = TeamViewController(team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        if let splitViewController = splitViewController {
            let navigationController = UINavigationController(rootViewController: teamViewController)
            splitViewController.showDetailViewController(navigationController, sender: nil)
        } else if let navigationController = navigationController {
            navigationController.pushViewController(teamViewController, animated: true)
        }
    }

}
