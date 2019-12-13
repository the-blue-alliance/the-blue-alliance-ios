import CoreData
import Foundation
import TBAKit

@objc(Webcast)
public class Webcast: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Webcast> {
        return NSFetchRequest<Webcast>(entityName: "Webcast")
    }

    public var channel: String {
        guard let channel = channelString else {
            fatalError("Save Webcast before accessing channel")
        }
        return channel
    }

    public var type: String {
        guard let type = typeString else {
            fatalError("Save Webcast before accessing type")
        }
        return type
    }

    public var events: [Event] {
        guard let eventsMany = eventsMany, let events = eventsMany.allObjects as? [Event] else {
            return []
        }
        return events
    }

    @NSManaged private var channelString: String?
    @NSManaged public private(set) var file: String?
    @NSManaged private var typeString: String?
    @NSManaged private var eventsMany: NSSet?

}

// MARK: Generated accessors for eventsMany
extension Webcast {

    @objc(removeEventsManyObject:)
    @NSManaged internal func removeFromEventsMany(_ value: Event)

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
                                    #keyPath(Webcast.typeString), model.type,
                                    #keyPath(Webcast.channelString), model.channel)

        return findOrCreate(in: context, matching: predicate, configure: { (webcast) in
            // Required: type, channel
            webcast.typeString = model.type
            webcast.channelString = model.channel
            webcast.file = model.file
        })
    }

}

extension Webcast: Orphanable {

    public var isOrphaned: Bool {
        return events.count == 0
    }

}
