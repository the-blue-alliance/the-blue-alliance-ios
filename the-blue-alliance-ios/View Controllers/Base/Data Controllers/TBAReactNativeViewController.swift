import CoreData
import Crashlytics
import Foundation
import React
import TBAKit
import UIKit

protocol TBAReactNativeViewControllerDelegate: AnyObject {
    var appProperties: [String: Any]? { get }
}

class TBAReactNativeViewController: TBAViewController {

    // MARK: - React Native

    var moduleName: String

    // MARK: - TBAReactNativeVC

    private var rootView: RCTRootView?
    weak var delegate: TBAReactNativeViewControllerDelegate?

    // MARK: - Init

    init(moduleName: String, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.moduleName = moduleName

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        NotificationCenter.default.addObserver(self, selector: #selector(handleReactNativeErrorNotification(_:)), name: NSNotification.Name.RCTJavaScriptDidFailToLoad, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        attemptToSetupRootView()
    }

    // MARK: - TBAViewController overrides

    override func reloadData() {
        if let rootView = rootView {
            // View is loaded - we need to update our info now
            if let appProperties = delegate?.appProperties {
                // Update our data with new data
                rootView.appProperties = appProperties
            } else if hasNoDataAfterRefresh {
                // Existing data is gone - show no data
                showNoDataView()
                self.rootView = nil
            } else {
                assertionFailure("Unhandled edge case around showing React Native data we should fix")
            }
        } else {
            // Attempt to load our view - otherwise, show no data and disable refreshing
            attemptToSetupRootView()
        }
    }

    // MARK: - Private Methods

    var hasNoDataAfterRefresh: Bool {
        guard let vc = self as? Stateful & Refreshable else {
            assertionFailure("TBAReactNativeViewController superclasses should conform to Stateful + Refreshable")
            return false
        }
        return vc.hasSuccessfullyRefreshed && vc.isDataSourceEmpty
    }

    /**
     Attempt to load our root React Native view and insert it in to our hiearchy. If we can't setup a root view, we'll
     add a no data view, if applicable.
     */
    private func attemptToSetupRootView(disableRefreshing: Bool = false) {
        // Attempt to load our view and insert it in to our hiearchy, if we have the data
        if let rootView = createRootView() {
            addRootViewToHiearchy(rootView)
            self.rootView = rootView
        } else if hasNoDataAfterRefresh {
            showNoDataView(disableRefreshing: disableRefreshing)
        }
    }

    /**
     Create a React Native root view for the supplied module/data.
     Will fail if we don't have any data or can't create the view.
     */
    private func createRootView() -> RCTRootView? {
        guard let initialProperties = delegate?.appProperties else {
            return nil
        }
        guard let sourceURL = sourceURL else {
            return nil
        }
        let rootView = RCTRootView(bundleURL: sourceURL, moduleName: moduleName, initialProperties: initialProperties, launchOptions: [:])
        rootView.delegate = self
        rootView.sizeFlexibility = .height
        return rootView
    }

    private func addRootViewToHiearchy(_ rootView: RCTRootView) {
        scrollView.addSubview(rootView)
        rootView.autoMatch(.width, to: .width, of: scrollView)
        rootView.autoPinEdgesToSuperviewEdges()
    }

    private func showNoDataView(disableRefreshing: Bool = false) {
        guard let vc = self as? Stateful & Refreshable else {
            return
        }
        if let rootView = rootView {
            rootView.removeFromSuperview()
        }
        vc.showNoDataView()
        if disableRefreshing {
            vc.disableRefreshing()
        }
    }

    // MARK: - Notifications

    @objc func handleReactNativeErrorNotification(_ sender: NSNotification) {
        if let error = sender.userInfo?["error"] as? Error {
            Crashlytics.sharedInstance().recordError(error)
        }
        showNoDataView(disableRefreshing: true)
    }

    // MARK: - React Native

    var sourceURL: URL? {
        #if DEBUG
        return debugSourceURL
        #else
        return prodSourceURL
        #endif
    }

    /**
     URL to use for React Native bundle in when running in Debug configuration.
     If local server is up and running, will use local server. Otherwise, we'll attempt to use the production bundle.
     */
    fileprivate var debugSourceURL: URL? {
        let debugSourceURL = URL(string: "http://localhost:8081/index.ios.bundle")
        if let debugSourceURL = debugSourceURL.reachableURL {
            return debugSourceURL
        }
        return prodSourceURL
    }

    var prodSourceURL: URL? {
        // Try to get our documents directory - this shouldn't fail, but just in case...
        guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return nil
        }

        let fallbackURL = Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        // Check if downloaded bundle (/Documents/ios/main.jsbundle) exists - otherwise use our bundled/shipped bundle
        let bundleURL = documentsDirectory.appendingPathComponent(ReactNativeService.BundleName.downloaded.rawValue)
        return (try? bundleURL.checkResourceIsReachable()) ?? false ? bundleURL : fallbackURL
    }

}

extension TBAReactNativeViewController: RCTRootViewDelegate {

    func rootViewDidChangeIntrinsicSize(_ rootView: RCTRootView!) {
        rootView.autoSetDimension(.height, toSize: rootView.intrinsicContentSize.height)
    }

}
