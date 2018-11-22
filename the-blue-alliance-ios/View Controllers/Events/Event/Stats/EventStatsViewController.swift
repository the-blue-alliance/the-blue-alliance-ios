import Foundation
import CoreData
import UIKit
import React

class EventStatsViewController: TBAViewController, Observable, ReactNative {

    private let event: Event

    // MARK: - React Native

    private lazy var eventStatsView: RCTRootView? = {
        // Event stats only exist for 2016 and onward
        if event.year!.intValue < 2016 {
            return nil
        }

        let moduleName = "EventInsights\(event.year!.stringValue)"
        let eventStatsView = RCTRootView(bundleURL: sourceURL,
                                         moduleName: moduleName,
                                         initialProperties: event.insights?.insightsDictionary ?? [:],
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

    init(event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        styleInterface()

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

    // MARK: Interface Methods

    func styleInterface() {
        guard let eventStatsView = eventStatsView else {
            showErrorView()
            return
        }

        scrollView.addSubview(eventStatsView)
        eventStatsView.autoMatch(.width, to: .width, of: scrollView)
        eventStatsView.autoPinEdgesToSuperviewEdges()
    }

    func updateEventStatsView() {
        if let eventStatsView = eventStatsView, let insights = event.insights {
            eventStatsView.appProperties = insights.insightsDictionary
        }
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
        showNoDataView()
        // Disable refreshing if we hit an error
        disableRefreshing()
    }

}

extension EventStatsViewController: RCTRootViewDelegate {

    func rootViewDidChangeIntrinsicSize(_ rootView: RCTRootView!) {
        rootView.autoSetDimension(.height, toSize: rootView.intrinsicContentSize.height)
    }

}

extension EventStatsViewController: Refreshable {

    var refreshKey: String? {
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
        return insights.qual == nil || insights.playoff == nil
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchEventInsights(key: event.key!, completion: { (insights, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event stats - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)

                if let insights = insights {
                    let event = backgroundContext.object(with: self.event.objectID) as! Event
                    event.insert(insights)

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

extension EventStatsViewController: Stateful {

    var noDataText: String {
        return "No stats for event"
    }

}
