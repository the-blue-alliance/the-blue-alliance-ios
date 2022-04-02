import CoreData

extension Searchable where Self: NSManagedObject {

    public var uniqueIdentifier: String {
        return objectID.uriRepresentation().absoluteString
    }

}
