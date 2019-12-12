import CoreData
import Foundation
import TBAKit

@objc(Webcast)
public class Webcast: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Webcast> {
        return NSFetchRequest<Webcast>(entityName: "Webcast")
    }

    @NSManaged public fileprivate(set) var channel: String
    @NSManaged public fileprivate(set) var file: String?
    @NSManaged public fileprivate(set) var type: String
    @NSManaged public fileprivate(set) var events: NSSet
    
}

// MARK: Generated accessors for events
extension Webcast {

    @objc(addEventsObject:)
    @NSManaged internal func addToEvents(_ value: Event)

    @objc(removeEventsObject:)
    @NSManaged internal func removeFromEvents(_ value: Event)

    @objc(addEvents:)
    @NSManaged internal func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged internal func removeFromEvents(_ values: NSSet)

}

extension Webcast: Managed {

    /**
     Insert a Webcast with values from a TBAKit Webcast model in to the managed object context.

     - Important: Method does not manage relationship between Webcast and Event.

     - Parameter model: The TBAKit Webcast representation to set values from.

     - Parameter eventKey: The key for the Event the Webcast belongs to.

     - Parameter context: The NSManagedContext to insert the Webcast in to.

     - Returns: The inserted Webcast.
     */
    public static func insert(_ model: TBAWebcast, in context: NSManagedObjectContext) -> Webcast {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(Webcast.type), model.type,
                                    #keyPath(Webcast.channel), model.channel)

        return findOrCreate(in: context, matching: predicate, configure: { (webcast) in
            // Required: type, channel
            webcast.type = model.type
            webcast.channel = model.channel
            webcast.file = model.file
        })
    }

}

extension Webcast: Orphanable {

    public var isOrphaned: Bool {
        return events.count == 0
    }

}
