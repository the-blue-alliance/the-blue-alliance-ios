import CoreData
import Foundation
import React
import TBAKit
import UIKit

class EventStatsViewController: TBAReactNativeViewController, Observable {

    private let event: Event

    // MARK: - Observable

    typealias ManagedType = Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event

        super.init(moduleName: "EventInsights\(event.year!.stringValue)", persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

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

    var appProperties: [String : Any]? {
        return event.insights?.insightsDictionary
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
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchEventInsights(key: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let insights = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(insights)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}

extension EventStatsViewController: Stateful {

    var noDataText: String {
        return "No stats for event"
    }

}
