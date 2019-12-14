import CoreData
import Foundation
import TBAKit

@objc(EventInsights)
public class EventInsights: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventInsights> {
        return NSFetchRequest<EventInsights>(entityName: EventInsights.entityName)
    }

    @NSManaged public private(set) var playoff: [String: Any]?
    @NSManaged public private(set) var qual: [String: Any]?

    var event: Event {
        guard let event = eventOne else {
            fatalError("Save EventInsights before accessing event")
        }
        return event
    }

    @NSManaged private var eventOne: Event?

}

extension EventInsights: Managed {

    /**
     Insert an EventInsights with values from a TBAKit EventInsights model in to the managed object context.

     - Important: This method does not manage setting up a relationship between an Event and EventInsights.

     - Parameter model: The TBAKit EventInsights representation to set values from.

     - Parameter eventKey: The key for the Event the EventInsights belongs to.

     - Parameter context: The NSManagedContext to insert the EventInsights in to.

     - Returns: The inserted Event.
     */
    @discardableResult
    public static func insert(_ model: TBAEventInsights, eventKey: String, in context: NSManagedObjectContext) -> EventInsights {
        let predicate = NSPredicate(format: "%K.%K == %@",
                                    #keyPath(EventInsights.eventOne), Event.keyPath(), eventKey)

        return findOrCreate(in: context, matching: predicate) { (insights) in
            // TODO: Handle NSNull? At least write a test
            insights.qual = model.qual
            insights.playoff = model.playoff
        }
    }

}

extension EventInsights {

    public var insightsDictionary: [String: Any] {
        var insights: [String: [String: Any]] = [:]

        if let qual = qual {
            insights["qual"] = qual
        }

        if let playoff = playoff {
            insights["playoff"] = playoff
        }

        return insights
    }

}

extension EventInsights: Orphanable {

    public var isOrphaned: Bool {
        // EventInsights should never be orphaned because they'll cascade with an Event's deletion
        return eventOne == nil
    }

}
