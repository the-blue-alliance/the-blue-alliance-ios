import os
import Foundation
import TBAAPI

/**
 Service to periodically fetch from the /status endpoint
 */
// TODO: actor
public class StatusService: NSObject {

    static let defaultStatus = Components.Schemas.API_Status(
        current_season: 2025,
        max_season: 2025,
        is_datafeed_down: false,
        down_events: [],
        ios: Components.Schemas.API_Status_App_Version(
            min_app_version: -1,
            latest_app_version: -1
        ), android: Components.Schemas.API_Status_App_Version(
            min_app_version: -1,
            latest_app_version: -1
        ),
        max_team_page: 24
    )

    var retryService: RetryService

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: StatusService.self)
    )

    private let api: TBAAPI
    fileprivate var status: Components.Schemas.API_Status {
        didSet {
            // Self.logger.debug("Status: \(self.status, privacy: .public)")
            dispatchStatusChanged(status)
            dispatchFMSDown(status.is_datafeed_down)
            dispatchEvents(downEventKeys: status.down_events)
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
        return status.current_season
    }

    var maxSeason: Int {
        return status.max_season
    }

    init(api: TBAAPI, retryService: RetryService, userDefaults: UserDefaults) {
        self.api = api
        self.retryService = retryService
        self.userDefaults = userDefaults

        do {
            if let status = try userDefaults.getStatus() {
                self.status = status
                Self.logger.debug("Using UserDefaults Status")
            } else {
                self.status = Self.defaultStatus
                Self.logger.debug("Using default Status")
            }
        } catch {
            Self.logger.error("Error fetching Status from UserDefaults: \(error)")
            self.status = Self.defaultStatus
        }
        // Self.logger.debug("Init Status: \(self.status, privacy: .public)")

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

    func dispatchStatusChanged(_ status: Components.Schemas.API_Status) {
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

    fileprivate func updateStatusSubscribers(_ status: Components.Schemas.API_Status) {
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
        return statusService.status.down_events.contains(eventKey)
    }

}

fileprivate extension UserDefaults {

    private static let kStatus = "kStatus"

    func getStatus() throws -> Components.Schemas.API_Status? {
        guard let encodedStatus = object(forKey: Self.kStatus) as? Data else {
            return nil
        }
        return try PropertyListDecoder().decode(Components.Schemas.API_Status.self, from: encodedStatus)
    }

    func setStatus(status: Components.Schemas.API_Status) throws {
        let encodedStatus = try PropertyListEncoder().encode(status)
        set(encodedStatus, forKey: Self.kStatus)
    }

}
