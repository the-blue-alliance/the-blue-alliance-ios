import Foundation
import CoreData
import UIKit
import React

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
                        self.tbaKit.setLastModified(request!)
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
