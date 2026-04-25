import Foundation
import TBAAPI
import TBAUtils

struct AppStatus {
    let currentSeason: Int
    let maxSeason: Int
    let minAppVersion: Int
    let latestAppVersion: Int
    let isDatafeedDown: Bool
    let downEventKeys: [String]

    static var `default`: AppStatus {
        let year = Calendar.current.component(.year, from: Date())
        return AppStatus(
            currentSeason: year,
            maxSeason: year,
            minAppVersion: -1,
            latestAppVersion: -1,
            isDatafeedDown: false,
            downEventKeys: []
        )
    }

    init(
        currentSeason: Int,
        maxSeason: Int,
        minAppVersion: Int,
        latestAppVersion: Int,
        isDatafeedDown: Bool,
        downEventKeys: [String]
    ) {
        self.currentSeason = currentSeason
        self.maxSeason = maxSeason
        self.minAppVersion = minAppVersion
        self.latestAppVersion = latestAppVersion
        self.isDatafeedDown = isDatafeedDown
        self.downEventKeys = downEventKeys
    }

    init(apiStatus: APIStatus) {
        self.currentSeason = apiStatus.currentSeason
        self.maxSeason = apiStatus.maxSeason
        self.minAppVersion = apiStatus.ios.minAppVersion
        self.latestAppVersion = apiStatus.ios.latestAppVersion
        self.isDatafeedDown = apiStatus.isDatafeedDown
        self.downEventKeys = apiStatus.downEvents
    }
}

protocol StatusServiceProtocol: AnyObject {
    var status: AppStatus { get }
    var currentSeason: Int { get }
    var maxSeason: Int { get }

    func registerForStatusChanges(_ subscriber: StatusSubscribable)
    func registerForFMSStatusChanges(_ subscriber: FMSStatusSubscribable)
    func registerForEventStatusChanges(_ subscriber: EventStatusSubscribable, eventKey: EventKey)

    func registerRetryable(initiallyRetry: Bool)
    func unregisterRetryable()
}

public class StatusService: NSObject, StatusServiceProtocol {

    var retryService: RetryService

    private let reporter: any Reporter
    private let api: any TBAAPIProtocol

    private(set) var status: AppStatus = .default

    private let statusSubscribers = NSHashTable<AnyObject>.weakObjects()
    private let fmsStatusSubscribers = NSHashTable<AnyObject>.weakObjects()
    private let eventStatusSubscribers = NSMapTable<NSString, NSHashTable<AnyObject>>()

    private var previousFMSStatus: Bool = false
    private var previouslyDownEventKeys: [String] = []

    var currentSeason: Int { status.currentSeason }
    var maxSeason: Int { status.maxSeason }

    init(reporter: any Reporter, api: any TBAAPIProtocol, retryService: RetryService) {
        self.reporter = reporter
        self.api = api
        self.retryService = retryService

        super.init()
    }

    func fetchStatus() async {
        do {
            let apiStatus = try await api.getStatus()
            let newStatus = AppStatus(apiStatus: apiStatus)
            await MainActor.run { apply(newStatus) }
        } catch {
            reporter.record(error)
        }
    }

    @MainActor
    private func apply(_ newStatus: AppStatus) {
        status = newStatus
        dispatchStatusChanged(newStatus)
        dispatchFMSDown(newStatus.isDatafeedDown)
        dispatchEvents(downEventKeys: newStatus.downEventKeys)
    }

    private func dispatchStatusChanged(_ status: AppStatus) {
        for obj in statusSubscribers.allObjects {
            (obj as? StatusSubscribable)?.statusChanged(status: status)
        }
    }

    private func dispatchFMSDown(_ fmsStatus: Bool) {
        if fmsStatus != previousFMSStatus {
            for obj in fmsStatusSubscribers.allObjects {
                (obj as? FMSStatusSubscribable)?.fmsStatusChanged(isDatafeedDown: fmsStatus)
            }
        }
        previousFMSStatus = fmsStatus
    }

    private func dispatchEvents(downEventKeys: [String]) {
        let newlyDownEventKeys = downEventKeys.filter { !previouslyDownEventKeys.contains($0) }
        for eventKey in newlyDownEventKeys {
            updateEventSubscribers(eventKey: eventKey, isEventOffline: true)
        }

        let newlyUpEventKeys = previouslyDownEventKeys.filter { !downEventKeys.contains($0) }
        for eventKey in newlyUpEventKeys {
            updateEventSubscribers(eventKey: eventKey, isEventOffline: false)
        }

        previouslyDownEventKeys = downEventKeys
    }

    // MARK: - Subscription Registration

    func registerForStatusChanges(_ subscriber: StatusSubscribable) {
        statusSubscribers.add(subscriber as AnyObject)
    }

    func registerForFMSStatusChanges(_ subscriber: FMSStatusSubscribable) {
        fmsStatusSubscribers.add(subscriber as AnyObject)
    }

    func registerForEventStatusChanges(_ subscriber: EventStatusSubscribable, eventKey: EventKey) {
        let subscribers =
            eventStatusSubscribers.object(forKey: eventKey as NSString)
            ?? NSHashTable<AnyObject>.weakObjects()
        subscribers.add(subscriber as AnyObject)
        eventStatusSubscribers.setObject(subscribers, forKey: eventKey as NSString)
    }

    private func updateEventSubscribers(eventKey: EventKey, isEventOffline: Bool) {
        guard let subscribersTable = eventStatusSubscribers.object(forKey: eventKey as NSString)
        else {
            return
        }
        for obj in subscribersTable.allObjects {
            (obj as? EventStatusSubscribable)?.eventStatusChanged(isEventOffline: isEventOffline)
        }
    }

}

extension StatusService: Retryable {

    var retryInterval: TimeInterval {
        // Poll every 5 minutes for a new status object.
        return 5 * 60
    }

    func retry() {
        Task { await fetchStatus() }
    }

}

protocol StatusSubscribable: AnyObject {
    var statusService: any StatusServiceProtocol { get }

    func statusChanged(status: AppStatus)
}

extension StatusSubscribable {

    func registerForStatusChanges() {
        statusService.registerForStatusChanges(self)
    }

}

protocol FMSStatusSubscribable: AnyObject {
    var statusService: any StatusServiceProtocol { get }

    func fmsStatusChanged(isDatafeedDown: Bool)
}

extension FMSStatusSubscribable {

    func registerForFMSStatusChanges() {
        statusService.registerForFMSStatusChanges(self)
    }

}

protocol EventStatusSubscribable: AnyObject {
    var statusService: any StatusServiceProtocol { get }

    func eventStatusChanged(isEventOffline: Bool)
}

extension EventStatusSubscribable {

    func registerForEventStatusChanges(eventKey: EventKey) {
        statusService.registerForEventStatusChanges(self, eventKey: eventKey)
    }

    func isEventDown(eventKey: EventKey) -> Bool {
        return statusService.status.downEventKeys.contains(eventKey)
    }

}
