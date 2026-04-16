import Foundation
import MyTBAKit
import Photos
import UIKit

class PadRootViewController: UISplitViewController, RootController {

    let fcmTokenProvider: FCMTokenProvider
    let myTBA: MyTBA
    let myTBAStores: MyTBAStores
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let pushService: PushService
    let urlOpener: URLOpener
    let statusService: StatusService
    let dependencies: Dependencies

    lazy fileprivate var masterViewController: PadMasterViewController = {
        return PadMasterViewController(fcmTokenProvider: fcmTokenProvider,
                                       myTBA: myTBA,
                                       myTBAStores: myTBAStores,
                                       pasteboard: pasteboard,
                                       photoLibrary: photoLibrary,
                                       pushService: pushService,
                                       statusService: statusService,
                                       urlOpener: urlOpener,
                                       dependencies: dependencies)
    }()

    lazy var emptyNavigationController: UINavigationController = {
       guard let emptyViewController = Bundle.main.loadNibNamed("EmptyViewController", owner: nil, options: nil)?.first as? UIViewController else {
           fatalError("Unable to load empty view controller")
        }

        let navigationController = UINavigationController(rootViewController: emptyViewController)
        navigationController.restorationIdentifier = kNoSelectionNavigationController

        return navigationController
    }()

    init(fcmTokenProvider: FCMTokenProvider, myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, pushService: PushService, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.fcmTokenProvider = fcmTokenProvider
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.pushService = pushService
        self.statusService = statusService
        self.urlOpener = urlOpener
        self.dependencies = dependencies

        super.init(nibName: nil, bundle: nil)

        let masterNavigationController = UINavigationController(rootViewController: masterViewController)
        viewControllers = [masterNavigationController, emptyNavigationController]

        preferredDisplayMode = .oneBesideSecondary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private class PadMasterViewController: ContainerViewController, RootController {

    let fcmTokenProvider: FCMTokenProvider
    let myTBA: MyTBA
    let myTBAStores: MyTBAStores
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let pushService: PushService
    let statusService: StatusService
    let urlOpener: URLOpener

    var searchController: UISearchController!

    init(fcmTokenProvider: FCMTokenProvider, myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard?, photoLibrary: PHPhotoLibrary?, pushService: PushService, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.fcmTokenProvider = fcmTokenProvider
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.pushService = pushService
        self.statusService = statusService
        self.urlOpener = urlOpener

        let rootTableViewController = PadRootTableViewController(dependencies: dependencies)

        super.init(viewControllers: [rootTableViewController], dependencies: dependencies)

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


    func _push(_ viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        showDetailViewController(navigationController, sender: nil)
    }

}

extension PadMasterViewController: SearchContainer, SearchContainerDelegate, SearchViewControllerDelegate {}

extension PadMasterViewController: PadRootTableViewControllerDelegate {

    func rootTypeSelected(_ rootType: RootType) {
        let viewController: UIViewController = {
            switch rootType {
            case .events:
                return eventsViewController
            case .teams:
                return teamsViewController
            case .districts:
                return districtsViewController
            case .myTBA:
                return myTBAViewController
            case .settings:
                return settingsViewController
            }
        }()

        if rootType.supportsPush {
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            _push(viewController)
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

        let type = RootType.allCases[indexPath.row]

        cell.textLabel?.text = type.title
        cell.imageView?.image = type.icon
        cell.imageView?.tintColor = UIColor.tabBarTintColor
        cell.accessoryType =  type.supportsPush ? .disclosureIndicator : .none

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
