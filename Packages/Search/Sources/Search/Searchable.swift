import CoreSpotlight
import Foundation
import Intents

public let TBAActivityTypeEvent = "com.the-blue-alliance.tba.Event"
public let TBAActivityTypeTeam = "com.the-blue-alliance.tba.Team"
public let TBAActivityURL = "kTBAActivityURL"

/**
 Identifies a Core Data class as being Searchable in-app and via Spotlight. Values are used by CoreSpotlight index and
 NSUserActivity to ensure that we don't duplicate search results.
 */
public protocol Searchable {

    static var entityName: String { get }

    /// Unique identifier to use for this object - since we index Core Data models, this will be the objectID URIRepresentation
    var uniqueIdentifier: String { get }

    /// Search attributes for this object
    var searchAttributes: CSSearchableItemAttributeSet { get }

    /// Boolean indicating if the object has been curated by the user and should rank higher in search
    var userCurated: Bool { get }

    /// URL where we can access the object online - import to prevent duplication of search results from the web + local index
    var webURL: URL { get }

}

extension Searchable {

    public var userActivity: NSUserActivity {
        let userInfo: [String: Any] = [
            TBAActivityURL: webURL
        ]

        let contentAttributeSet = searchAttributes

        // When adding new searchable activities, make sure to add the activity type to Info.plist
        let activity = NSUserActivity(activityType: "com.the-blue-alliance.tba.\(type(of: self).entityName)")
        activity.title = contentAttributeSet.displayName

        contentAttributeSet.contentURL = webURL
        contentAttributeSet.relatedUniqueIdentifier = uniqueIdentifier
        contentAttributeSet.userCurated = userCurated ? NSNumber(value: 1) : nil
        activity.contentAttributeSet = contentAttributeSet

        activity.userInfo = userInfo
        activity.webpageURL = webURL
        activity.requiredUserInfoKeys = Set(userInfo.keys)

        activity.isEligibleForPublicIndexing = true
        activity.isEligibleForSearch = true
        activity.isEligibleForHandoff = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = uniqueIdentifier

        return activity
    }

    public var relevantShortcut: INRelevantShortcut {
        let shortcut = INShortcut(userActivity: userActivity)
        let relevantShortcut = INRelevantShortcut(shortcut: shortcut)

        // When viewing an Event, the shortcut is relevant during the Event, or if the user is at the Event location.
        var relevanceProviders: [INRelevanceProvider] = []
        if let startDate = searchAttributes.startDate, let endDate = searchAttributes.endDate {
            relevanceProviders.append(INDateRelevanceProvider(start: startDate, end: endDate))
        }
        if let lat = searchAttributes.latitude, let lng = searchAttributes.longitude {
            // Show the name of the Event location
            let identifier = searchAttributes.namedLocation ?? searchAttributes.locationString ?? searchAttributes.displayName ?? "---"
            relevanceProviders.append(INLocationRelevanceProvider(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat.doubleValue,
                                                                                                                          longitude: lng.doubleValue),
                                                                                           radius: 1000,
                                                                                           identifier: identifier)))
        }
        relevantShortcut.relevanceProviders = relevanceProviders

        return relevantShortcut
    }

}
