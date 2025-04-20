import Foundation
import TBAAPI
import TBAModels
import os

/**
 Service to periodically fetch from the /status endpoint
 */
public class StatusService: NSObject {

    var retryService: RetryService

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: StatusService.self)
    )

    private let api: TBAAPI
    fileprivate var status: Status {
        didSet {
            Self.logger.debug("Status: \(self.status, privacy: .public)")
            dispatchStatusChanged(status)
            dispatchFMSDown(status.datafeedDown)
            dispatchEvents(downEventKeys: status.downEvents)
        }
    }
    private let userDefaults: UserDefaults

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

    init(api: TBAAPI, retryService: RetryService, userDefaults: UserDefaults) {
        self.api = api
        self.retryService = retryService
        self.userDefaults = userDefaults

        let defaultStatus = Status(
            ios: AppInfo(
                latestAppVersion: -1,
                minAppVersion: -1
            ),
            currentSeason: 2025,
            downEvents: [],
            datafeedDown: false,
            maxSeason: 2025,
            maxTeamPage: 21
        )

        do {
            if let status = try userDefaults.getStatus() {
                self.status = status
                Self.logger.debug("Using UserDefaults Status")
            } else {
                self.status = defaultStatus
                Self.logger.debug("Using default Status")
            }
        } catch {
            Self.logger.error("Error fetching Status from UserDefaults: \(error)")
            self.status = defaultStatus
        }
        Self.logger.debug("Init Status: \(self.status, privacy: .public)")

        super.init()
    }

    func fetchStatus() async {
        do {
            let status = try await api.getStatus()
            Self.logger.debug("Fetched Status from API")
            self.status = status
        } catch {
            Self.logger.error("Error fetching Status from API: \(error)")
        }
        do {
            try self.userDefaults.setStatus(status: status)
            Self.logger.debug("Saved API Status to UserDefaults")
        } catch {
            Self.logger.error("Error saving Status to UserDefaults: \(error)")
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
            subscriber.statusChanged(statusService: self)
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
        Task {
            await fetchStatus()
        }
    }

}

@objc protocol StatusSubscribable: AnyObject {
    var statusService: StatusService { get }

    func statusChanged(statusService: StatusService)
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
        return statusService.status.downEvents.contains(eventKey)
    }

}

fileprivate extension UserDefaults {

    private static let kStatus = "kStatus"

    func getStatus() throws -> Status? {
        guard let encodedStatus = object(forKey: Self.kStatus) as? Data else {
            return nil
        }
        return try PropertyListDecoder().decode(Status.self, from: encodedStatus)
    }

    func setStatus(status: Status) throws {
        let encodedStatus = try PropertyListEncoder().encode(status)
        set(encodedStatus, forKey: Self.kStatus)
    }

}
