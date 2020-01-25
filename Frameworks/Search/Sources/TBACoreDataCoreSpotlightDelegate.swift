import CoreData
import CoreSpotlight
import Foundation

public class TBACoreDataCoreSpotlightDelegate: NSCoreDataCoreSpotlightDelegate {

    override public func attributeSet(for object: NSManagedObject) -> CSSearchableItemAttributeSet? {
        guard let object = object as? Searchable else {
            return nil
        }
        return object.searchAttributes
    }

}
