import Foundation
import UIKit
import React
import TBAKit
import CoreData

class MatchBreakdownViewController: TBAViewController, Observable, ReactNative {

    private let match: Match

    // MARK: - React Native

    private lazy var breakdownView: RCTRootView? = {
        // Match breakdowns only exist for 2015 and onward
        if match.event!.year!.intValue < 2015 {
            return nil
        }
        guard let breakdownData = dataForBreakdown() else {
            return nil
        }
        let moduleName = "MatchBreakdown\(match.event!.year!.stringValue)"
        let breakdownView = RCTRootView(bundleURL: sourceURL,
                                        moduleName: moduleName,
                                        initialProperties: breakdownData,
                                        launchOptions: [:])
        breakdownView!.delegate = self
        breakdownView!.sizeFlexibility = .height
        // TODO: loadingView
        return breakdownView
    }()

    // MARK: - Observable

    typealias ManagedType = Match
    lazy var contextObserver: CoreDataContextObserver<Match> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(match: Match, persistentContainer: NSPersistentContainer) {
        self.match = match

        super.init(persistentContainer: persistentContainer)

        contextObserver.observeObject(object: match, state: .updated) { [unowned self] (_, _) in
            DispatchQueue.main.async {
                self.updateBreakdownView()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Move this... out. Somewhere else. In the ReactNative Protocol
        NotificationCenter.default.addObserver(self, selector: #selector(handleReactNativeErrorNotification(_:)), name: NSNotification.Name.RCTJavaScriptDidFailToLoad, object: nil)

        styleInterface()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateBreakdownView()
    }

    // MARK: Interface Methods

    func styleInterface() {
        // Override our default background color to match the match breakdown background color
        view.backgroundColor = UIColor.colorWithRGB(rgbValue: 0xdddddd)

        guard let breakdownView = breakdownView else {
            showErrorView()
            return
        }

        removeNoDataView()
        scrollView.addSubview(breakdownView)

        breakdownView.autoMatch(.width, to: .width, of: scrollView)
        breakdownView.autoPinEdgesToSuperviewEdges()
        print("breakdownView.reactViewController: \(breakdownView.reactViewController)")
    }

    func updateBreakdownView() {
        if let breakdownView = breakdownView, let breakdownData = dataForBreakdown() {
            breakdownView.appProperties = breakdownData
        }
    }

    // MARK: Private

    func dataForBreakdown() -> [String: Any]? {
        // TODO: Support all alliances
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/273
        guard var redBreakdown = match.breakdown?["red"] as? [String: Any] else {
            return nil
        }
        guard var blueBreakdown = match.breakdown?["blue"] as? [String: Any] else {
            return nil
        }

        // For 2015 - map `coopertition` and `coopertition_points` points in to each breakdown dictionary
        if let coopertition = match.breakdown?["coopertition"] as? String, let coopertitionPoints = match.breakdown?["coopertition_points"] as? Int {
            // Setting these individually, since I can't seem to do a 'for in' to modify the above maps
            redBreakdown["coopertition"] = coopertition
            redBreakdown["coopertition_points"] = coopertitionPoints

            blueBreakdown["coopertition"] = coopertition
            blueBreakdown["coopertition_points"] = coopertitionPoints
        }

        return ["redTeams": match.redAllianceTeamNumbers,
                "redBreakdown": redBreakdown,
                "blueTeams": match.blueAllianceTeamNumbers,
                "blueBreakdown": blueBreakdown,
                "compLevel": match.compLevelString!]
    }


    override func reloadViewAfterRefresh() {
        if isDataSourceEmpty {
            showNoDataView()
        } else {
            updateBreakdownView()
        }
    }

    // MARK: - ReactNative
    // MARK: - Notifications

    // TODO: This sucks, but also, we can't have @objc in a protocol extension so
    @objc func handleReactNativeErrorNotification(_ sender: NSNotification) {
        reactNativeError(sender)
    }

    func showErrorView() {
        showNoDataView()
        // Disable refreshing if we hit an error
        disableRefreshing()
    }

}

extension MatchBreakdownViewController: RCTRootViewDelegate {

    func rootViewDidChangeIntrinsicSize(_ rootView: RCTRootView!) {
        rootView.autoSetDimension(.height, toSize: rootView.intrinsicContentSize.height)
    }

}

extension MatchBreakdownViewController: Refreshable {

    var refreshKey: String? {
        return match.key
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return match.breakdown == nil
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchMatch(key: match.key!, { (modelMatch, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh match breakdown - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                if let modelMatch = modelMatch {
                    // TODO: Match can never be deleted
                    let event = backgroundContext.object(with: self.match.event!.objectID) as! Event
                    Match.insert(modelMatch, event: event, in: backgroundContext)
                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: request!)
                    }
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

}

extension MatchBreakdownViewController: Stateful {

    var noDataText: String {
        return "No breakdown for match"
    }

}
