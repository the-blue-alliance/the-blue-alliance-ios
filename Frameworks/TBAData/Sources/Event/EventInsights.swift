import CoreData
import Foundation
import TBAKit

extension EventInsights {

    public var playoff: [String: Any]? {
        return getValue(\EventInsights.playoffRaw)
    }

    public var qual: [String: Any]? {
        return getValue(\EventInsights.qualRaw)
    }

    public var event: Event {
        guard let event = getValue(\EventInsights.eventRaw) else {
            fatalError("Save EventInsights before accessing event")
        }
        return event
    }

}

@objc(EventInsights)
public class EventInsights: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventInsights> {
        return NSFetchRequest<EventInsights>(entityName: EventInsights.entityName)
    }

    @NSManaged var playoffRaw: [String: Any]?
    @NSManaged var qualRaw: [String: Any]?
    @NSManaged var eventRaw: Event?

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
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(EventInsights.eventRaw.keyRaw), eventKey)

        return findOrCreate(in: context, matching: predicate) { (insights) in
            // TODO: Handle NSNull? At least write a test
            insights.qualRaw = model.qual
            insights.playoffRaw = model.playoff
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
        return eventRaw == nil
    }

}
