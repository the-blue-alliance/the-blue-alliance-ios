import CoreData
import Crashlytics
import Foundation
import React
import TBAData
import TBAKit
import UIKit

class EventStatsViewController: TBAReactNativeViewController, Observable {

    private let event: Event
    private var eventStatsUnsupported = false

    // MARK: - Observable

    typealias ManagedType = Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event

        super.init(moduleName: "EventInsights", persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        delegate = self

        contextObserver.observeObject(object: event, state: .updated) { [weak self] (_, _) in
            DispatchQueue.main.async {
                self?.reloadData()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EventStatsViewController: TBAReactNativeViewControllerDelegate {

    func showUnsupportedView() {
        eventStatsUnsupported = true
        showNoDataView(disableRefreshing: true)
    }

    var appProperties: [String : Any]? {
        var insights = event.insights?.insightsDictionary
        insights?["year"] = event.year!.stringValue
        return insights
    }

}

extension EventStatsViewController: Refreshable {

    var refreshKey: String? {
        let key = event.getValue(\Event.key!)
        return "\(key)_insights"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh event stats until the event is over
        return event.getValue(\Event.endDate)?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        guard let insights = event.getValue(\Event.insights) else {
            return true
        }
        return insights.getValue(\EventInsights.qual) == nil || insights.getValue(\EventInsights.playoff) == nil
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventInsights(key: event.key!) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let insights = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(insights)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        addRefreshOperations([operation])
    }

}

extension EventStatsViewController: Stateful {

    var noDataText: String {
        if eventStatsUnsupported {
            return "\(event.year!.stringValue) Event Insights is not supported"
        }
        return "No stats for event"
    }

}
