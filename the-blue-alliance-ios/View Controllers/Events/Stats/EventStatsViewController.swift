import Foundation
import CoreData
import TBAKit
import UIKit
import React

class EventStatsViewController: TBAViewController, Refreshable, Observable, ReactNative {

    private let event: Event

    // MARK: - React Native

    private lazy var eventStatsView: RCTRootView? = {
        // Event stats only exist for 2016 and onward
        if Int(event.year) < 2016 {
            return nil
        }
        guard let insights = event.insights else {
            return nil
        }

        let moduleName = "EventInsights\(event.year)"
        let eventStatsView = RCTRootView(bundleURL: sourceURL,
                                         moduleName: moduleName,
                                         initialProperties: insights,
                                         launchOptions: [:])
        // TODO: eventStatsView.loadingView
        eventStatsView!.delegate = self
        eventStatsView!.sizeFlexibility = .height
        return eventStatsView
    }()

    // MARK: - Observable

    typealias ManagedType = Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer) {
        self.event = event

        super.init(persistentContainer: persistentContainer)

        contextObserver.observeObject(object: event, state: .updated) { [unowned self] (_, _) in
            DispatchQueue.main.async {
                self.updateEventStatsView()
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateEventStatsView()
    }

    // MARK: Interface Methods

    func styleInterface() {
        guard let eventStatsView = eventStatsView else {
            showErrorView()
            return
        }

        removeNoDataView()
        scrollView.addSubview(eventStatsView)

        eventStatsView.autoMatch(.width, to: .width, of: scrollView)
        eventStatsView.autoPinEdgesToSuperviewEdges()
    }

    func updateEventStatsView() {
        if let eventStatsView = eventStatsView, let insights = event.insights {
            eventStatsView.appProperties = insights
        }
    }

    func showNoDataView() {
        showNoDataView(with: "No stats for event")
    }

    // MARK: - Refreshable

    var refreshKey: String {
        return "\(event.key!)_insights"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh event stats until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        guard let insights = event.insights else {
            return true
        }
        // https://github.com/ZachOrr/TBAKit/issues/11
        let qual = insights["qual"]
        let playoff = insights["playoff"]
        return qual == nil || playoff == nil
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventInsights(key: event.key!, completion: { (insights, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event stats - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                backgroundEvent.insights = insights

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func reloadViewAfterRefresh() {
        if isDataSourceEmpty {
            showNoDataView()
        } else {
            updateEventStatsView()
        }
    }

    // MARK: - ReactNative
    // MARK: - Notifications

    // TODO: This sucks, but also, we can't have @objc in a protocol extension so
    @objc func handleReactNativeErrorNotification(_ sender: NSNotification) {
        reactNativeError(sender)
    }

    func showErrorView() {
        showNoDataView(with: "Unable to load event stats")
        // Disable refreshing if we hit an error
        disableRefreshing()
    }

}

extension EventStatsViewController: RCTRootViewDelegate {

    func rootViewDidChangeIntrinsicSize(_ rootView: RCTRootView!) {
        rootView.autoSetDimension(.height, toSize: rootView.intrinsicContentSize.height)
    }

}
