import Foundation
import CoreData
import TBAKit
import UIKit
import React

class EventStatsViewController: TBAViewController, Observable, ReactNative {
    
    var event: Event!
    
    // MARK: - React Native
    
    lazy internal var reactBridge: RCTBridge = {
        return RCTBridge(delegate: self, launchOptions: [:])
    }()
    private var eventStatsView: RCTRootView?
    
    // MARK: - Persistable
    
    override var persistentContainer: NSPersistentContainer! {
        didSet {
            contextObserver.observeObject(object: event, state: .updated) { [weak self] (_, _) in
                DispatchQueue.main.async {
                    self?.updateEventStatsView()
                }
            }
        }
    }
    
    // MARK: - Observable
    
    typealias ManagedType = Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()
    
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
        
    func updateEventStatsView() {
        // Event stats only exist for 2016 and onward
        if Int(event.year) < 2016 {
            return
        }
        
        guard let insights = event.insights else {
            showNoDataView()
            return
        }

        // If the event stats view already exists, don't set it up again
        // Only update the properties for the view
        if let eventStatsView = eventStatsView {
            eventStatsView.appProperties = insights
            return
        }
        
        let moduleName = "EventInsights\(event!.year)"

        guard let eventStatsView = RCTRootView(bridge: reactBridge, moduleName: moduleName, initialProperties: insights) else {
            showErrorView()
            return
        }
        self.eventStatsView = eventStatsView
        
        // breakdownView.loadingView
        eventStatsView.delegate = self
        eventStatsView.sizeFlexibility = .height
        
        removeNoDataView()
        scrollView.addSubview(eventStatsView)
        
        eventStatsView.autoMatch(.width, to: .width, of: scrollView)
        eventStatsView.autoPinEdgesToSuperviewEdges()
    }
    
    func showNoDataView() {
        showNoDataView(with: "No stats for event")
    }
    
    // MARK: - RCTBridgeDelegate
    
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        // Fetch our downloaded JS bundle (or our local packager, if we're running in debug mode)
        return sourceURL
    }
    // fallbackSourceURL
    
    // MARK: Refresh
    
    override func shouldNoDataRefresh() -> Bool {
        guard let insights = event.insights else {
            return true
        }
        // https://github.com/ZachOrr/TBAKit/issues/11
        let qual = insights["qual"]
        let playoff = insights["playoff"]
        return qual == nil || playoff == nil;
    }
    
    override func refresh() {
        removeNoDataView()
        
        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventInsights(key: event.key!, completion: { (insights, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event stats - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                backgroundEvent.insights = insights
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event stats - database error")
                }
                
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }
    
    override func reloadViewAfterRefresh() {
        if shouldNoDataRefresh() {
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
