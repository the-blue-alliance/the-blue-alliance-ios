import CoreData
import TBAData
import TBAKit
import TBAUtils
import Foundation

/**
 Service to periodically fetch from the /status endpoint
 */
public class StatusService: NSObject {

    var retryService: RetryService

    private let operationQueue = OperationQueue()

    private let bundle: Bundle
    private let errorRecorder: ErrorRecorder
    private let persistentContainer: NSPersistentContainer
    private let tbaKit: TBAKit

    lazy var status: Status = {
        if let status = Status.status(in: persistentContainer.viewContext) {
            return status
        } else {
            guard let status = Status.fromPlist(bundle: bundle, in: persistentContainer.viewContext) else {
                fatalError("Cannot setup Status for StatusService")
            }
            _ = persistentContainer.viewContext.saveOrRollback(errorRecorder: errorRecorder)
            return status
        }
    }()

    lazy var contextObserver: CoreDataContextObserver<Status> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    private let statusSubscribers: NSHashTable<StatusSubscribable> = NSHashTable.weakObjects()
    private let fmsStatusSubscribers: NSHashTable<FMSStatusSubscribable> = NSHashTable.weakObjects()
    private let eventStatusSubscribers: NSMapTable<NSString, NSHashTable<EventStatusSubscribable>> = NSMapTable()

    // Keep internal state of previously-down Events so we can dispatch when they're back up
    private var previousFMSStatus: Bool = false
    private var previouslyDownEventKeys: [String] = []

    var currentSeason: Int {
        return status.currentSeason
    }

    var maxSeason: Int {
        return status.maxSeason
    }

    init(bundle: Bundle = Bundle.main, errorRecorder: ErrorRecorder, persistentContainer: NSPersistentContainer, retryService: RetryService, tbaKit: TBAKit) {
        self.bundle = bundle
        self.errorRecorder = errorRecorder
        self.persistentContainer = persistentContainer
        self.retryService = retryService
        self.tbaKit = tbaKit

        super.init()
    }

    func setupStatusObservers() {
        contextObserver.observeObject(object: status, state: .updated) { [weak self] (status, _) in
            self?.dispatchStatusChanged(status)
            self?.dispatchFMSDown(status.isDatafeedDown)
            self?.dispatchEvents(downEventKeys: status.downEvents.map({ $0.key }))
        }
    }

    internal func fetchStatus(completion: ((_ error: Error?) -> Void)? = nil) -> TBAKitOperation {
        return tbaKit.fetchStatus { [self] (result, notModified) in
            switch result {
            case .failure(let error):
                completion?(error)
            case .success(let status):
                let context = persistentContainer.newBackgroundContext()
                context.performChangesAndWait({
                    if !notModified, let status = status {
                        Status.insert(status, in: context)
                    }
                }, errorRecorder: errorRecorder)
                completion?(nil)
            }
        }
    }

    func dispatchStatusChanged(_ status: Status) {
        updateStatusSubscribers(status)
    }

    func dispatchFMSDown(_ fmsStatus: Bool) {
        if fmsStatus != previousFMSStatus {
            updateFMSSubscribers(isDatafeedDown: fmsStatus)
        }
        previousFMSStatus = fmsStatus
    }

    func dispatchEvents(downEventKeys: [String]) {
        // Dispatch new events are down
        let newlyDownEventKeys = downEventKeys.filter({ !previouslyDownEventKeys.contains($0) })
        for eventKey in newlyDownEventKeys {
            updateEventSubscribers(eventKey: eventKey, isEventOffline: true)
        }

        // Dispatch old events are up
        let newlyUpEventKeys = previouslyDownEventKeys.filter({ !downEventKeys.contains($0) })
        for eventKey in newlyUpEventKeys {
            updateEventSubscribers(eventKey: eventKey, isEventOffline: false)
        }

        // Save our state
        previouslyDownEventKeys = downEventKeys
    }

    // MARK: - Status Notifications

    fileprivate func registerForStatusChanges(_ subscriber: StatusSubscribable) {
        statusSubscribers.add(subscriber)
    }

    fileprivate func registerForFMSStatusChanges(_ subscriber: FMSStatusSubscribable) {
        fmsStatusSubscribers.add(subscriber)
    }

    fileprivate func registerForEventStatusChanges(_ subscriber: EventStatusSubscribable, eventKey: String) {
        let subscribers = eventStatusSubscribers.object(forKey: eventKey as NSString) ?? NSHashTable.weakObjects()
        subscribers.add(subscriber)
        eventStatusSubscribers.setObject(subscribers, forKey: eventKey as NSString)
    }

    fileprivate func updateStatusSubscribers(_ status: Status) {
        for subscriber in self.statusSubscribers.allObjects {
            subscriber.statusChanged(status: status)
        }
    }

    fileprivate func updateFMSSubscribers(isDatafeedDown: Bool) {
        for subscriber in self.fmsStatusSubscribers.allObjects {
            subscriber.fmsStatusChanged(isDatafeedDown: isDatafeedDown)
        }
    }

    fileprivate func updateEventSubscribers(eventKey: String, isEventOffline: Bool) {
        guard let subscribersTable = eventStatusSubscribers.object(forKey: eventKey as NSString) else {
            return
        }
        for subscriber in subscribersTable.allObjects {
            subscriber.eventStatusChanged(isEventOffline: isEventOffline)
        }
    }

}

extension StatusService: Retryable {

    var retryInterval: TimeInterval {
        // Poll every... 5 mins for a new status object
        return 5 * 60
    }

    func retry() {
        let op = fetchStatus()
        operationQueue.addOperation(op)
    }

}

@objc protocol StatusSubscribable {
    var statusService: StatusService { get }

    func statusChanged(status: Status)
}

extension StatusSubscribable {

    func registerForStatusChanges() {
        statusService.registerForStatusChanges(self)
    }

}

@objc protocol FMSStatusSubscribable {
    var statusService: StatusService { get }

    func fmsStatusChanged(isDatafeedDown: Bool)
}

extension FMSStatusSubscribable {

    func registerForFMSStatusChanges() {
        statusService.registerForFMSStatusChanges(self)
    }

}

@objc protocol EventStatusSubscribable {
    var statusService: StatusService { get }

    func eventStatusChanged(isEventOffline: Bool)
}

extension EventStatusSubscribable {

    func registerForEventStatusChanges(eventKey: String) {
        statusService.registerForEventStatusChanges(self, eventKey: eventKey)
    }

    func isEventDown(eventKey: String) -> Bool {
        let downEventKeys = statusService.status.downEvents.map({ $0.key })
        return downEventKeys.contains(eventKey)
    }

}
