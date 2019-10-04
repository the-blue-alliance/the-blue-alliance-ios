import CoreData
import Foundation
import TBAKit

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

    public var isOrphaned: Bool {
        return events?.count == 0
    }

}
