import Foundation
import UIKit
import React
import TBAKit
import CoreData

class MatchBreakdownViewController: TBAViewController, Observable, ReactNative {

    private let match: Match

    // MARK: - React Native
    
    lazy internal var reactBridge: RCTBridge = {
        return RCTBridge(delegate: self, launchOptions: [:])
    }()
    private var breakdownView: RCTRootView?

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
    }

    func updateBreakdownView() {
        // Match breakdowns only exist for 2015 and onward
        if Int(match.event!.year) < 2015 {
            return
        }

        guard let breadownData = dataForBreakdown() else {
            showNoDataView()
            return
        }

        // If the breakdown view already exists, don't set it up again
        // Only update the properties for the view
        if let breakdownView = breakdownView {
            breakdownView.appProperties = breadownData
            return
        }

        let moduleName = "MatchBreakdown\(match.event!.year)"

        guard let breakdownView = RCTRootView(bridge: reactBridge, moduleName: moduleName, initialProperties: breadownData) else {
            showErrorView()
            return
        }
        self.breakdownView = breakdownView

        // breakdownView.loadingView
        breakdownView.delegate = self
        breakdownView.sizeFlexibility = .height

        removeNoDataView()
        scrollView.addSubview(breakdownView)

        breakdownView.autoMatch(.width, to: .width, of: scrollView)
        breakdownView.autoPinEdgesToSuperviewEdges()
    }

    // MARK: Private

    func dataForBreakdown() -> [String: Any]? {
        guard let redBreakdown = match.redBreakdown else {
            return nil
        }
        guard let blueBreakdown = match.blueBreakdown else {
            return nil
        }

        let redAllianceTeams = match.redAlliance?.array as? [Team]
        let redAlliance = redAllianceTeams?.map({ (team) -> String in
            return "\(team.teamNumber)"
        })

        let blueAllianceTeams = match.blueAlliance?.array as? [Team]
        let blueAlliance = blueAllianceTeams?.map({ (team) -> String in
            return "\(team.teamNumber)"
        })

        return ["redTeams": redAlliance ?? [],
                "redBreakdown": redBreakdown,
                "blueTeams": blueAlliance ?? [],
                "blueBreakdown": blueBreakdown,
                "compLevel": match.compLevel!]
    }

    // MARK: - RCTBridgeDelegate

    func sourceURL(for bridge: RCTBridge!) -> URL! {
        // Fetch our downloaded JS bundle (or our loctaal packager, if we're running in debug mode)
        return sourceURL
    }
    // fallbackSourceURL

    // MARK: Refresh

    override func shouldNoDataRefresh() -> Bool {
        return match.redBreakdown == nil || match.blueBreakdown == nil
    }

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchMatch(key: match.key!, { (modelMatch, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh match breakdown - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.match.event!.objectID) as! Event

                if let modelMatch = modelMatch {
                    backgroundEvent.addToMatches(Match.insert(with: modelMatch, for: backgroundEvent, in: backgroundContext))
                }

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func reloadViewAfterRefresh() {
        if shouldNoDataRefresh() {
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

    func showNoDataView() {
        showNoDataView(with: "No breakdown for match")
    }

    func showErrorView() {
        showNoDataView(with: "Unable to load event stats")
        // Disable refreshing if we hit an error
        disableRefreshing()
    }

}

extension MatchBreakdownViewController: RCTRootViewDelegate {

    func rootViewDidChangeIntrinsicSize(_ rootView: RCTRootView!) {
        rootView.autoSetDimension(.height, toSize: rootView.intrinsicContentSize.height)
    }

}
