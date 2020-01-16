import CoreData
import Crashlytics
import Foundation
import TBAData
import TBAKit
import UIKit

class EventStatsViewController: TBAViewController, Observable {

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

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contextObserver.observeObject(object: event, state: .updated) { _, _ in
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }

    override func reloadData() {
        // Pass
    }

}

extension EventStatsViewController: Refreshable {

    var refreshKey: String? {
        return "\(event.key)_insights"
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
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventInsights(key: event.key) { (result, notModified) in
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
            return "\(event.year) Event Insights is not supported"
        }
        return "No stats for event"
    }

}
