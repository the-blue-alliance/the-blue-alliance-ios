import CoreData
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class PhoneRootViewController: UITabBarController, RootController {

    let fcmTokenProvider: FCMTokenProvider
    let myTBA: MyTBA
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let pushService: PushService
    let searchService: SearchService
    let statusService: StatusService
    let urlOpener: URLOpener
    let persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit
    let userDefaults: UserDefaults

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

        viewControllers = [eventsViewController, teamsViewController, districtsViewController, myTBAViewController, settingsViewController].compactMap({ (viewController) -> UIViewController? in
            return UINavigationController(rootViewController: viewController)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - RootController

    func continueSearch(_ searchText: String) -> Bool {
        // Pop to root of Events tab, show search
        // Dismiss existing modal view controller
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false)
        }

        selectedIndex = 0
        guard let navigationController = selectedViewController as? UINavigationController else {
            return false
        }
        navigationController.popToRootViewController(animated: false)

        guard let searchContainerViewController = navigationController.viewControllers.first as? SearchContainer else {
            return false
        }
        searchContainerViewController.searchController.searchBar.text = searchText
        searchContainerViewController.searchController.isActive = true

        return true
    }

    func show(event: Event) -> Bool {
        guard let searchContainerViewController = show(index: 0) else {
            return false
        }
        searchContainerViewController.eventSelected(event)
        return true
    }

    func show(team: Team) -> Bool {
        guard let searchContainerViewController = show(index: 1) else {
            return false
        }
        searchContainerViewController.teamSelected(team)
        return true
    }

    private func show(index: Int) -> SearchViewControllerDelegate? {
        // Dismiss existing modal view controller
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false)
        }

        selectedIndex = index
        guard let navigationController = selectedViewController as? UINavigationController else {
            return nil
        }
        navigationController.popToRootViewController(animated: false)

        guard let searchContainerViewController = navigationController.viewControllers.first as? SearchViewControllerDelegate else {
            return nil
        }

        return searchContainerViewController
    }

}
