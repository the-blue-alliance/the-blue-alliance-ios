import CoreData
import Foundation

/**
 Service to periodically fetch from the /status endpoint
 */
class StatusService: NSObject {

    private let bundle: Bundle
    private let persistentContainer: NSPersistentContainer
    var retryService: RetryService
    private let tbaKit: TBAKit

    fileprivate lazy var status: Status = {
        if let status = Status.status(in: persistentContainer.viewContext) {
            return status
        } else if let status = Status.fromPlist(bundle: bundle, in: persistentContainer.viewContext) {
            return status
        } else {
            fatalError("Cannot setup Status for StatusService")
        }
    }()
    lazy var contextObserver: CoreDataContextObserver<Status> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    private let fmsStatusSubscribers: NSHashTable<FMSStatusSubscribable> = NSHashTable.weakObjects()
    private let eventStatusSubscribers: NSMapTable<NSString, NSHashTable<EventStatusSubscribable>> = NSMapTable()

    // Keep internal state of previously-down Events so we can dispatch when they're back up
    private var previousFMSStatus: Bool = false
    private var previouslyDownEventKeys: [String] = []

    var minAppVersion: Int {
        return status.minAppVersion?.intValue ?? -1
    }
    var currentSeason: Int {
        return status.currentSeason!.intValue
    }
    var maxSeason: Int {
        return status.maxSeason!.intValue
    }

    init(bundle: Bundle = Bundle.main, persistentContainer: NSPersistentContainer, retryService: RetryService, tbaKit: TBAKit) {
        self.bundle = bundle
        self.persistentContainer = persistentContainer
        self.retryService = retryService
        self.tbaKit = tbaKit

        super.init()
    }

    func setupStatusObservers() {
        contextObserver.observeObject(object: status, state: .updated) { [weak self] (status, _) in
            let fmsStatus = status.isDatafeedDown!.boolValue
            self?.dispatchFMSDown(fmsStatus)

            let downEventKeys = (status.downEvents!.allObjects as! [EventKey]).map({ $0.key! })
            self?.dispatchEvents(downEventKeys: downEventKeys)
        }
    }

    @discardableResult
    internal func fetchStatus(completion: ((_ error: Error?) -> Void)? = nil) -> URLSessionDataTask {
        return tbaKit.fetchStatus { (status, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let status = status {
                    Status.insert(status, in: context)
                }
            })
            completion?(error)
        }
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

    fileprivate func registerForFMSStatusChanges(_ subscriber: FMSStatusSubscribable) {
        fmsStatusSubscribers.add(subscriber)
    }

    fileprivate func registerForEventStatusChanges(_ subscriber: EventStatusSubscribable, eventKey: String) {
        let subscribers = eventStatusSubscribers.object(forKey: eventKey as NSString) ?? NSHashTable.weakObjects()
        subscribers.add(subscriber)
        eventStatusSubscribers.setObject(subscribers, forKey: eventKey as NSString)
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
        fetchStatus()
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
        let downEventKeys = (statusService.status.downEvents?.allObjects as? [EventKey] ?? []).map({ $0.key! })
        return downEventKeys.contains(eventKey)
    }

}
