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
        let searchViewController = SearchViewController(searchService: searchService, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
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
    var myTBA: MyTBA { get }
    var pasteboard: UIPasteboard? { get }
    var photoLibrary: PHPhotoLibrary? { get }
    var remoteConfigService: RemoteConfigService { get }
    var statusService: StatusService { get }
    var urlOpener: URLOpener { get }
}

extension SearchContainerDelegate where Self: ContainerViewController {

    func eventSelected(_ event: Event) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let eventViewController = EventViewController(event: event, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, remoteConfigService: remoteConfigService, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let nav = UINavigationController(rootViewController: eventViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

    func teamSelected(_ team: Team) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let teamViewController = TeamViewController(team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, remoteConfigService: remoteConfigService, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let nav = UINavigationController(rootViewController: teamViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

}
