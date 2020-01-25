import CoreData
import CoreSpotlight
import Foundation
import Search
import TBAData
import TBAKit
import TBAUtils

private struct SearchConstants {
    static let lastRefreshEventsAllKey = "kLastRefreshAllEvents"
    static let lastRefreshTeamsAllKey = "kLastRefreshAllTeams"
}

public class SearchService: NSObject {

    let batchSize = 100

    private let errorRecorder: ErrorRecorder
    private let indexDelegate: TBACoreDataCoreSpotlightDelegate
    private let persistentContainer: NSPersistentContainer
    private let searchIndex: CSSearchableIndex
    private let statusService: StatusService
    private let tbaKit: TBAKit
    private let userDefaults: UserDefaults

    private(set) var refreshOperation: Operation?
    private let operationQueue = OperationQueue()

    public init(errorRecorder: ErrorRecorder, indexDelegate: TBACoreDataCoreSpotlightDelegate, persistentContainer: NSPersistentContainer, searchIndex: CSSearchableIndex, statusService: StatusService, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.errorRecorder = errorRecorder
        self.indexDelegate = indexDelegate
        self.persistentContainer = persistentContainer
        self.searchIndex = searchIndex
        self.statusService = statusService
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults

        super.init()

        searchIndex.indexDelegate = self
    }

    // MARK: Public Methods

    @discardableResult
    public func refresh(userInitiated: Bool = false) -> Operation {
        if let refreshOperation = refreshOperation {
            return refreshOperation
        }

        let refreshOperation = Operation()

        // Only automatically refresh all Events once - otherwise, fetch only the current season events
        let lastRefreshAllEvents = userDefaults.value(forKey: SearchConstants.lastRefreshEventsAllKey) as? Date

        var eventsOperation: TBAKitOperation!
        if lastRefreshAllEvents == nil || userInitiated {
            eventsOperation = tbaKit.fetchEvents() { [unowned self] (result, notModified) in
                let managedObjectContext = self.persistentContainer.newBackgroundContext()
                managedObjectContext.performChangesAndWait({
                    if !notModified, let events = try? result.get() {
                        // Batch insert/save our events
                        // Fetch all of our existing events so we can clean up orphans
                        let oldEvents = Event.fetch(in: managedObjectContext)

                        var newEvents: [Event] = []
                        for i in stride(from: events.startIndex, to: events.endIndex, by: self.batchSize) {
                            let subEvents = Array(events[i..<min(i + self.batchSize, events.count)])
                            newEvents.append(contentsOf: subEvents.map {
                                return Event.insert($0, in: managedObjectContext)
                            })
                            managedObjectContext.saveOrRollback(errorRecorder: self.errorRecorder)
                        }

                        // Delete orphaned Events for this year
                        let orphanedEvents = Array(Set(oldEvents).subtracting(Set(newEvents)))
                        for i in stride(from: orphanedEvents.startIndex, to: orphanedEvents.endIndex, by: self.batchSize) {
                            let subEvents = Array(orphanedEvents[i..<min(i + self.batchSize, orphanedEvents.count)])
                            subEvents.forEach {
                                managedObjectContext.delete($0)
                            }
                            managedObjectContext.saveOrRollback(errorRecorder: self.errorRecorder)
                        }
                    }
                }, saved: {
                    self.tbaKit.storeCacheHeaders(eventsOperation)
                    self.userDefaults.set(Date(), forKey: SearchConstants.lastRefreshEventsAllKey)
                    self.userDefaults.synchronize()
                }, errorRecorder: self.errorRecorder)
            }
        } else {
            let year = statusService.currentSeason
            eventsOperation = tbaKit.fetchEvents(year: year) { [unowned self] (result, notModified) in
                let context = self.persistentContainer.newBackgroundContext()
                context.performChangesAndWait({
                    if !notModified, let events = try? result.get() {
                        Event.insert(events, year: year, in: context)
                    }
                }, saved: {
                    self.tbaKit.storeCacheHeaders(eventsOperation)
                }, errorRecorder: self.errorRecorder)
            }
        }

        // Only automatically refresh all Teams once-per-day
        let lastRefreshAllTeams = userDefaults.value(forKey: SearchConstants.lastRefreshTeamsAllKey) as? Date

        var diffInDays = 0
        if let lastRefreshAllTeams = lastRefreshAllTeams, let days = Calendar.current.dateComponents([.day], from: lastRefreshAllTeams, to: Date()).day {
            diffInDays = days
        }

        var teamsOperation: TBAKitOperation?
        if lastRefreshAllTeams == nil || userInitiated || diffInDays >= 1 {
            teamsOperation = tbaKit.fetchTeams() { [unowned self] (result, notModified) in
                let managedObjectContext = self.persistentContainer.newBackgroundContext()
                managedObjectContext.performChangesAndWait({
                    if !notModified, let teams = try? result.get() {
                        // Batch insert/save our teams
                        // Fetch all of our existing teams so we can clean up orphans
                        let oldTeams = Team.fetch(in: managedObjectContext)

                        var newTeams: [Team] = []
                        for i in stride(from: teams.startIndex, to: teams.endIndex, by: self.batchSize) {
                            let subTeams = Array(teams[i..<min(i + self.batchSize, teams.count)])
                            newTeams.append(contentsOf: subTeams.map {
                                return Team.insert($0, in: managedObjectContext)
                            })
                            managedObjectContext.saveOrRollback(errorRecorder: self.errorRecorder)
                        }

                        // Delete orphaned Teams for this year
                        let orphanedTeams = Array(Set(oldTeams).subtracting(Set(newTeams)))
                        for i in stride(from: orphanedTeams.startIndex, to: orphanedTeams.endIndex, by: self.batchSize) {
                            let subTeams = Array(orphanedTeams[i..<min(i + self.batchSize, orphanedTeams.count)])
                            subTeams.forEach {
                                managedObjectContext.delete($0)
                            }
                            managedObjectContext.saveOrRollback(errorRecorder: self.errorRecorder)
                        }
                    }
                }, saved: {
                    self.tbaKit.storeCacheHeaders(teamsOperation!)
                    self.userDefaults.set(Date(), forKey: SearchConstants.lastRefreshTeamsAllKey)
                    self.userDefaults.synchronize()
                }, errorRecorder: self.errorRecorder)
            }
        }

        let clearRefreshOperation = BlockOperation {
            self.refreshOperation = nil
        }

        [eventsOperation, teamsOperation].compactMap({ $0 }).forEach { (op: Operation) in
            clearRefreshOperation.addDependency(op)
            refreshOperation.addDependency(op)
        }

        operationQueue.addOperations([eventsOperation, teamsOperation, clearRefreshOperation].compactMap({ $0 }), waitUntilFinished: false)
        self.refreshOperation = refreshOperation

        return refreshOperation
    }

    public func searchableUserActivity(_ searchable: Searchable) -> NSUserActivity {
        let searchAttributes = searchable.searchAttributes
        let userInfo: [String: Any] = [
            "uniqueIdentifier": searchable.uniqueIdentifier,
            "webURL": searchable.webURL
        ]

        // When adding new searchable activities, make sure to add the activity type to Info.plist
        let activity = NSUserActivity(activityType: "com.the-blue-alliance.tba.\(type(of: searchable).entityName)")
        activity.title = searchAttributes.displayName
        activity.contentAttributeSet = searchAttributes
        // Forgive me father for I cannot use keyPaths
        activity.userInfo = userInfo
        activity.webpageURL = searchable.webURL
        activity.requiredUserInfoKeys = Set(userInfo.keys)

        activity.isEligibleForPublicIndexing = true
        activity.isEligibleForSearch = true
        // TODO: Support handoff, eventually

        return activity
    }

    public func deleteSearchIndex(errorRecorder: ErrorRecorder) {
        searchIndex.deleteAllSearchableItems { [unowned self] (error) in
            if let error = error {
                print(error)
                self.errorRecorder.recordError(error)
            }
        }
    }

}

extension SearchService: CSSearchableIndexDelegate {

    public func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexAllSearchableItemsWithAcknowledgementHandler acknowledgementHandler: @escaping () -> Void) {
        indexDelegate.searchableIndex(searchableIndex, reindexAllSearchableItemsWithAcknowledgementHandler: acknowledgementHandler)
    }

    public func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexSearchableItemsWithIdentifiers identifiers: [String], acknowledgementHandler: @escaping () -> Void) {
        indexDelegate.searchableIndex(searchableIndex, reindexSearchableItemsWithIdentifiers: identifiers, acknowledgementHandler: acknowledgementHandler)
    }

}
