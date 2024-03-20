import CoreData
import CoreSpotlight
import Foundation
import Intents
import Search
import TBAData
import TBAKit
import TBAUtils
import UIKit

private struct SearchConstants {
    static let lastRefreshEventsAllKey = "kLastRefreshAllEvents"
    static let lastRefreshTeamsAllKey = "kLastRefreshAllTeams"
}

public class SearchService: NSObject, TeamsRefreshProvider {

    let batchSize = 1000

    private let application: UIApplication
    private let errorRecorder: ErrorRecorder
    private let indexDelegate: TBACoreDataCoreSpotlightDelegate
    private let persistentContainer: NSPersistentContainer
    private let searchIndex: CSSearchableIndex
    private let statusService: StatusService
    private let tbaKit: TBAKit
    private let userDefaults: UserDefaults

    private(set) var refreshOperation: Operation?
    private var eventsRefreshOperation: Operation?
    private var teamsRefreshOperation: Operation?

    private(set) var operationQueue = OperationQueue()

    public init(application: UIApplication, errorRecorder: ErrorRecorder, indexDelegate: TBACoreDataCoreSpotlightDelegate, persistentContainer: NSPersistentContainer, searchIndex: CSSearchableIndex, statusService: StatusService, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.application = application
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

        var eventsOperation: TBAKitOperation!
        if shouldRefreshAllEvents || userInitiated {
            eventsOperation = tbaKit.fetchEvents() { [unowned self] (result, notModified) in
                guard case .success(let events) = result, !notModified else {
                    return
                }

                // TODO: NSBatchInsertRequest/NSBatchDeleteRequest
                let managedObjectContext = self.persistentContainer.newBackgroundContext()
                managedObjectContext.performChangesAndWait({
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
                }, saved: {
                    self.tbaKit.storeCacheHeaders(eventsOperation)
                    self.userDefaults.set(Date(), forKey: SearchConstants.lastRefreshEventsAllKey)
                    self.userDefaults.synchronize()
                }, errorRecorder: self.errorRecorder)
            }
        } else {
            let year = statusService.currentSeason
            eventsOperation = tbaKit.fetchEvents(year: year) { [unowned self] (result, notModified) in
                guard case .success(let events) = result, !notModified else {
                    return
                }

                let context = self.persistentContainer.newBackgroundContext()
                context.performChangesAndWait({
                    Event.insert(events, year: year, in: context)
                }, saved: {
                    self.tbaKit.storeCacheHeaders(eventsOperation)
                }, errorRecorder: self.errorRecorder)
            }
        }
        eventsOperation.completionBlock = {
            self.eventsRefreshOperation = nil
        }
        self.eventsRefreshOperation = eventsOperation

        let teamsOperation = refreshTeams(userInitiated: userInitiated)
        teamsOperation?.completionBlock = {
            self.teamsRefreshOperation = nil
        }
        self.teamsRefreshOperation = teamsOperation

        // If our refresh is system-initiated, setup a background task which will be
        // to ensure all tasks finish before the app is killed in the background
        var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
        if userInitiated {
            backgroundTaskIdentifier = self.application.beginBackgroundTask {
                self.operationQueue.cancelAllOperations()
                if let backgroundTaskIdentifier = backgroundTaskIdentifier {
                    self.application.endBackgroundTask(backgroundTaskIdentifier)
                }
            }
        }

        let refreshOperation = Operation()
        refreshOperation.completionBlock = {
            self.refreshOperation = nil
            if let backgroundTaskIdentifier = backgroundTaskIdentifier {
                self.application.endBackgroundTask(backgroundTaskIdentifier)
            }
        }

        [eventsOperation, teamsOperation].compactMap({ $0 }).forEach { (op: Operation) in
            refreshOperation.addDependency(op)
        }

        operationQueue.addOperations([eventsOperation, teamsOperation, refreshOperation].compactMap({ $0 }), waitUntilFinished: false)
        self.refreshOperation = refreshOperation

        return refreshOperation
    }

    public var shouldRefreshAllEvents: Bool {
        // Only automatically refresh all Events once - otherwise, fetch only the current season events
        let lastRefreshAllEvents = userDefaults.value(forKey: SearchConstants.lastRefreshEventsAllKey) as? Date
        return lastRefreshAllEvents == nil
    }

    public var shouldRefreshTeams: Bool {
        // Only automatically refresh all Teams once-per-day
        let lastRefreshAllTeams = userDefaults.value(forKey: SearchConstants.lastRefreshTeamsAllKey) as? Date

        var diffInDays = 0
        if let lastRefreshAllTeams = lastRefreshAllTeams, let days = Calendar.current.dateComponents([.day], from: lastRefreshAllTeams, to: Date()).day {
            diffInDays = days
        }

        return lastRefreshAllTeams == nil || diffInDays >= 1
    }

    public func refreshTeams(userInitiated: Bool) -> Operation? {
        if let teamsRefreshOperation = teamsRefreshOperation {
            return teamsRefreshOperation
        }

        var teamsOperation: TBAKitOperation?
        if shouldRefreshTeams || userInitiated {
            teamsOperation = tbaKit.fetchTeams(simple: !userInitiated) { [unowned self] (result, notModified) in
                guard case .success(let teams) = result, !notModified else {
                    return
                }

                // TODO: NSBatchInsertRequest/NSBatchDeleteRequest
                let managedObjectContext = self.persistentContainer.newBackgroundContext()
                managedObjectContext.performChangesAndWait({
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
                }, saved: {
                    self.tbaKit.storeCacheHeaders(teamsOperation!)
                    self.userDefaults.set(Date(), forKey: SearchConstants.lastRefreshTeamsAllKey)
                    self.userDefaults.synchronize()
                }, errorRecorder: self.errorRecorder)
            }
        }
        return teamsOperation
    }

    public func deleteSearchIndex(errorRecorder: ErrorRecorder) {
        deleteLastRefresh()

        indexDelegate.deleteSpotlightIndex { [unowned self] (error) in
            if let error = error {
                self.errorRecorder.record(error)
            }
        }
    }

    // MARK: - Private Methods

    private func deleteLastRefresh() {
        self.userDefaults.removeObject(forKey: SearchConstants.lastRefreshEventsAllKey)
        self.userDefaults.removeObject(forKey: SearchConstants.lastRefreshTeamsAllKey)
        self.userDefaults.synchronize()
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
