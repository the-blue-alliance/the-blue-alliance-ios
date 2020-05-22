import CoreData
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class PadRootViewController: UISplitViewController, RootController {

    let fcmTokenProvider: FCMTokenProvider
    let myTBA: MyTBA
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let pushService: PushService
    let searchService: SearchService
    let urlOpener: URLOpener
    let statusService: StatusService
    let persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit
    let userDefaults: UserDefaults

    lazy fileprivate var masterViewController: PadMasterViewController = {
        return PadMasterViewController(fcmTokenProvider: fcmTokenProvider,
                                       myTBA: myTBA,
                                       pasteboard: pasteboard,
                                       photoLibrary: photoLibrary,
                                       pushService: pushService,
                                       searchService: searchService,
                                       statusService: statusService,
                                       urlOpener: urlOpener,
                                       persistentContainer: persistentContainer,
                                       tbaKit: tbaKit,
                                       userDefaults: userDefaults)
    }()

    lazy var emptyNavigationController: UINavigationController = {
       guard let emptyViewController = Bundle.main.loadNibNamed("EmptyViewController", owner: nil, options: nil)?.first as? UIViewController else {
           fatalError("Unable to load empty view controller")
        }

        let navigationController = UINavigationController(rootViewController: emptyViewController)
        navigationController.restorationIdentifier = kNoSelectionNavigationController

        return navigationController
    }()

    init(fcmTokenProvider: FCMTokenProvider, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, pushService: PushService, searchService: SearchService, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.fcmTokenProvider = fcmTokenProvider
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.pushService = pushService
        self.searchService = searchService
        self.statusService = statusService
        self.urlOpener = urlOpener
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults

        super.init(nibName: nil, bundle: nil)

        let masterNavigationController = UINavigationController(rootViewController: masterViewController)
        viewControllers = [masterNavigationController, emptyNavigationController]

        // splitViewController.preferredDisplayMode = .allVisible
        // splitViewController.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: Remove these
    // MARK: - RootController

    func continueSearch(_ searchText: String) -> Bool {
        return masterViewController.continueSearch(searchText)
    }

    func show(event: Event) -> Bool {
        return masterViewController.show(event: event)
    }

    func show(team: Team) -> Bool {
        return masterViewController.show(team: team)
    }

}

private class PadMasterViewController: ContainerViewController, RootController {

    let fcmTokenProvider: FCMTokenProvider
    let myTBA: MyTBA
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let pushService: PushService
    let searchService: SearchService
    let statusService: StatusService
    let urlOpener: URLOpener

    var searchController: UISearchController!

    init(fcmTokenProvider: FCMTokenProvider, myTBA: MyTBA, pasteboard: UIPasteboard?, photoLibrary: PHPhotoLibrary?, pushService: PushService, searchService: SearchService, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.fcmTokenProvider = fcmTokenProvider
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.pushService = pushService
        self.searchService = searchService
        self.statusService = statusService
        self.urlOpener = urlOpener

        let rootTableViewController = PadRootTableViewController(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [rootTableViewController], persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        rootTableViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchController()
    }

    // MARK: - RootController

    func continueSearch(_ searchText: String) -> Bool {
        // Pass
        return true
    }

    func show(event: Event) -> Bool {
        // Pass
        return true
    }

    func show(team: Team) -> Bool {
        // Pass
        return true
    }
    
}

extension PadMasterViewController: SearchContainer, SearchContainerDelegate, SearchViewControllerDelegate {}

extension PadMasterViewController: PadRootTableViewControllerDelegate {

    func rootTypeSelected(_ rootType: RootType) {
        switch rootType {
        case .events:
            navigationController?.pushViewController(eventsViewController, animated: true)
        case .teams:
            navigationController?.pushViewController(teamsViewController, animated: true)
        case .districts:
            navigationController?.pushViewController(districtsViewController, animated: true)
        case .myTBA:
            navigationController?.pushViewController(myTBAViewController, animated: true)
        case .settings:
            // TODO: Fix
            break
        }
    }

}

protocol PadRootTableViewControllerDelegate: AnyObject {
    func rootTypeSelected(_ rootType: RootType)
}

private class PadRootTableViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: PadRootTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        disableRefreshing()

        tableView.isScrollEnabled = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RootType.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell

        cell.textLabel?.text = RootType.allCases[indexPath.row].title
        cell.imageView?.image = RootType.allCases[indexPath.row].icon
        cell.imageView?.tintColor = UIColor.tabBarTintColor
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.rootTypeSelected(RootType.allCases[indexPath.row])
    }

    // MARK: - Refreshable

    var refreshKey: String? {
        return nil
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return false
    }

    func refresh() {
        // NOP
    }


    // MARK: - Stateful

    var noDataText: String? {
        return nil
    }

}

/*
extension PadRootViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        // If our split view controller is collapsed and we're trying to show a detail view,
        // push it on the master navigation stack
        if splitViewController.isCollapsed,
            // Need to get the VC for the currently selected tab...
            let masterNavigationController = tabBarController.selectedViewController as? UINavigationController {
            // We want to push the view controller, but make sure we're not pushing something in a nav controller
            guard let detailNavigationController = vc as? UINavigationController else {
                return false
            }

            guard let detailViewController = detailNavigationController.viewControllers.first else {
                return false
            }

            masterNavigationController.show(detailViewController, sender: nil)

            return true
        }

        return false
    }

    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        // If collapsing and detail view controller is not a no selection navigation view controller,
        // push the first view controller on to primary navigation view controller and return
        // the primary tab bar controller
        if let detailNavigationController = splitViewController.viewControllers.last as? UINavigationController,
            detailNavigationController.restorationIdentifier != kNoSelectionNavigationController {
            // This is a view controller we want to push
            if let masterNavigationController = tabBarController.selectedViewController as? UINavigationController {
                // Add the detail navigation controller stack to our root navigation controller
                masterNavigationController.viewControllers += detailNavigationController.viewControllers
                return tabBarController
            }
        }

        return splitViewController.viewControllers.first
    }

    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        // If our primary view controller is not a no selection view controller, pop the old one, return the tab bar,
        // and setup the detail view controller to be the primary view controller
        //
        // Otherwise, return our detail
        if let masterNavigationController = tabBarController.selectedViewController as? UINavigationController,
            masterNavigationController.topViewController?.restorationIdentifier != kNoSelectionNavigationController {
            // We want to seperate this event view controller in to the detail view controller
            if let detailViewControllers = masterNavigationController.popToRootViewController(animated: true) {
                let detailNavigationController = UINavigationController()
                detailNavigationController.viewControllers = detailViewControllers
                splitViewController.viewControllers = [tabBarController, detailNavigationController]

                return detailNavigationController
            }
        }

        return emptyNavigationController
    }

}
*/
