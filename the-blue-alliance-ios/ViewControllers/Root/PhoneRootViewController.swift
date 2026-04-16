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
    let myTBAStores: MyTBAStores
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let pushService: PushService
    let searchService: SearchService
    let statusService: StatusService
    let urlOpener: URLOpener
    let dependencies: Dependencies

    init(fcmTokenProvider: FCMTokenProvider, myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, pushService: PushService, searchService: SearchService, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.fcmTokenProvider = fcmTokenProvider
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.pushService = pushService
        self.searchService = searchService
        self.statusService = statusService
        self.urlOpener = urlOpener
        self.dependencies = dependencies

        super.init(nibName: nil, bundle: nil)

        viewControllers = [eventsViewController, teamsViewController, districtsViewController, myTBAViewController, settingsViewController].compactMap({ (viewController) -> UIViewController? in
            return UINavigationController(rootViewController: viewController)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
