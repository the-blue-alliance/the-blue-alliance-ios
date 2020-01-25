import CoreSpotlight
import Foundation

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
