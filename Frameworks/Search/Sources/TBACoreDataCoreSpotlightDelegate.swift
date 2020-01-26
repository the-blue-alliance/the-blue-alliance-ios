import CoreData
import CoreSpotlight
import Foundation

public class TBACoreDataCoreSpotlightDelegate: NSCoreDataCoreSpotlightDelegate {

    override public func attributeSet(for object: NSManagedObject) -> CSSearchableItemAttributeSet? {
        guard let object = object as? Searchable else {
            return nil
        }
        let attributes = object.searchAttributes
        attributes.contentURL = object.webURL
        attributes.relatedUniqueIdentifier = object.uniqueIdentifier
        attributes.userCurated = object.userCurated ? NSNumber(value: 1) : nil
        return attributes
    }

}
