import CoreData
import Foundation
import Search

extension Searchable where Self: NSManagedObject {

    public var uniqueIdentifier: String {
        return objectID.uriRepresentation().absoluteString
    }

}
