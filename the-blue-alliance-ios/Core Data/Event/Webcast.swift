import Foundation
import TBAKit
import CoreData

extension Webcast: Managed {

    /**
     Insert a Webcast with values from a TBAKit Webcast model in to the managed object context.

     - Important: Method does not manage relationship between Webcast and Event.

     - Parameter model: The TBAKit Webcast representation to set values from.

     - Parameter eventKey: The key for the Event the Webcast belongs to.

     - Parameter context: The NSManagedContext to insert the Webcast in to.

     - Returns: The inserted Webcast.
     */
    static func insert(_ model: TBAWebcast, in context: NSManagedObjectContext) -> Webcast {
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

    /**
     Insert an array of Webcasts with values from TBAKit Webcast models in to the managed object context. This method manages setting up the relationship between a Webcast and an Event and deleting orphaned Webcasts.

     - Parameter webcasts: The TBAKit Webcast representations to set values from.

     - Parameter event: The Event the Webcasts belongs to.

     - Parameter context: The NSManagedContext to insert the Webcasts in to.
     */
    static func insert(_ webcasts: [TBAWebcast], event: Event, in context: NSManagedObjectContext) {
        updateToManyRelationship(relationship: &event.webcasts, newValues: webcasts.map({
            return Webcast.insert($0, in: context)
        }), matchingOrphans: {
            // If an Webcast's only Event is this Webcast, it's an orphan now
            return $0.events?.allObjects as? [Event] == [event]
        }, in: context)
    }

}
