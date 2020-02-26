import CoreData
import CoreSpotlight
import Crashlytics
import Search
import TBAData
import Foundation
import UIKit

// Handles launching the app/setting up the view hiearchy from some handoff event
class HandoffService {

    private let persistentContainer: NSPersistentContainer
    private let rootViewController: UITabBarController

    var appSetup: Bool = false {
        didSet {
            if let searchText = self.continueSearchText {
                self.continueSearch(searchText)
            } else if let uri = self.continueURI {
                self.continueURI(uri)
            }
        }
    }
    private(set) var continueSearchText: String?
    private(set) var continueURI: URL?

    init(persistentContainer: NSPersistentContainer, rootViewController: UITabBarController) {
        self.persistentContainer = persistentContainer
        self.rootViewController = rootViewController
    }

    func application(continue userActivity: NSUserActivity) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb || userActivity.activityType == TBAActivityTypeEvent || userActivity.activityType == TBAActivityTypeTeam {
            let rawURL: URL? = {
                if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                    return userActivity.webpageURL
                }
                return userActivity.userInfo?[TBAActivityURL] as? URL
            }()

            guard let url = rawURL else {
                return false
            }

            // Remove / from our path components
            let pathComponents = url.pathComponents.filter { $0 != "/" }
            guard let type = pathComponents.first else {
                return false
            }
            // Get "second" basically
            guard let key = pathComponents.first(where: { $0 != type }) else {
                return false
            }
            if type == "event" {
                // See if we already have an Event with this key
                var event = Event.findOrFetch(in: persistentContainer.viewContext, matching: Event.predicate(key: key))
                let eventKeyRegex = try? NSRegularExpression(pattern: #"^\d{4}\w+$"#, options: [])
                // If the Event doesn't exist, but our key matches what we consider a "safe" regex, insert the Event and push
                if event == nil, let eventKeyRegex = eventKeyRegex, eventKeyRegex.numberOfMatches(in: key, options: [], range: NSRange(location: 0, length: key.count)) == 1 {
                    event = Event.insert(key, in: persistentContainer.viewContext)
                    persistentContainer.viewContext.saveOrRollback(errorRecorder: Crashlytics.sharedInstance())
                }
                guard let uri = event?.objectID.uriRepresentation() else {
                    return false
                }
                return continueURI(uri)
            } else if type == "team" {
                // See if we already have a Team with this key
                var team = Team.findOrFetch(in: persistentContainer.viewContext, matching: Team.predicate(key: key))
                let teamKeyRegex = try? NSRegularExpression(pattern: #"^frc\d+$"#, options: [])
                // If the Team doesn't exist, but our key matches what we consider a "safe" regex, insert the Team and push
                if team == nil, let teamKeyRegex = teamKeyRegex, teamKeyRegex.numberOfMatches(in: key, options: [], range: NSRange(location: 0, length: key.count)) == 1 {
                    team = Team.insert(key, in: persistentContainer.viewContext)
                    persistentContainer.viewContext.saveOrRollback(errorRecorder: Crashlytics.sharedInstance())
                }
                guard let uri = team?.objectID.uriRepresentation() else {
                    return false
                }
                return continueURI(uri)
            }
            return false
        } else if userActivity.activityType == CSSearchableItemActionType {
            guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String, let uri = URL(string: identifier) else {
                return false
            }
            return continueURI(uri)
        } else if userActivity.activityType == CSQueryContinuationActionType {
            guard let searchText = userActivity.userInfo?[CSSearchQueryString] as? String else {
                return false
            }
            return continueSearch(searchText)
        }
        return false
    }

    // MARK: - Private Methods

    @discardableResult
    private func continueSearch(_ searchText: String) -> Bool {
        guard appSetup else {
            continueSearchText = searchText
            return true
        }

        // Pop to root of Events tab, show search
        // Dismiss existing modal view controller
        if let presentedViewController = rootViewController.presentedViewController {
            presentedViewController.dismiss(animated: false)
        }

        rootViewController.selectedIndex = 0
        guard let navigationController = rootViewController.selectedViewController as? UINavigationController else {
            return false
        }
        navigationController.popToRootViewController(animated: false)

        guard let searchContainerViewController = navigationController.viewControllers.first as? SearchContainer else {
            return false
        }
        searchContainerViewController.searchController.searchBar.text = searchText
        searchContainerViewController.searchController.isActive = true

        return true
    }

    @discardableResult
    private func continueURI(_ uri: URL) -> Bool {
        guard appSetup else {
            continueURI = uri
            return true
        }

        guard let objectID = persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: uri) else {
            return false
        }

        // Dismiss existing modal view controller
        if let presentedViewController = rootViewController.presentedViewController {
            presentedViewController.dismiss(animated: false)
        }

        rootViewController.selectedIndex = 0
        guard let navigationController = rootViewController.selectedViewController as? UINavigationController else {
            return false
        }
        navigationController.popToRootViewController(animated: false)

        guard let searchContainerViewController = navigationController.viewControllers.first as? SearchViewControllerDelegate else {
            return false
        }

        let object = persistentContainer.viewContext.object(with: objectID)
        if let event = object as? Event {
            searchContainerViewController.eventSelected(event)
            return true
        } else if let team = object as? Team {
            searchContainerViewController.teamSelected(team)
            return true
        }
        return false
    }

}
