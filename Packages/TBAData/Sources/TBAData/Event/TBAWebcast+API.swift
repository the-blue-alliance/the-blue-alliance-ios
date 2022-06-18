import CoreData
import Foundation
import TBAKit

//extension Webcast {
//
//    public var displayName: String {
//        if type == "youtube" {
//            return "YouTube"
//        } else if type == "twitch" {
//            return "Twitch"
//        } else if type == "direct_link" {
//            // Convert our direct link string in to just the domain
//            // Ex: espn.com
//            guard let url = URL(string: channel), let host = url.host else {
//                return "website"
//            }
//            let parts = host.split(separator: ".")
//            // Only return last two components "etc.com"
//            return parts.dropFirst(max(parts.count - 2, 0)).joined(separator: ".")
//        }
//        return type
//    }
//
//    public var urlString: String? {
//        if type == "twitch" {
//            return "https://twitch.tv/\(channel)"
//        } else if type == "youtube" {
//            return "https://www.youtube.com/watch?v=\(channel)"
//        } else if type == "direct_link" {
//            return channel
//        }
//        return nil
//    }
//
//    public var channel: String {
//        guard let channel = getValue(\Webcast.channelRaw) else {
//            fatalError("Save Webcast before accessing channel")
//        }
//        return channel
//    }
//
//    public var date: Date? {
//        return getValue(\Webcast.dateRaw)
//    }
//
//    public var file: String? {
//        return getValue(\Webcast.fileRaw)
//    }
//
//    public var type: String {
//        guard let type = getValue(\Webcast.typeRaw) else {
//            fatalError("Save Webcast before accessing type")
//        }
//        return type
//    }
//
//    public var events: [Event] {
//        guard let eventsRaw = getValue(\Webcast.eventsRaw),
//            let events = eventsRaw.allObjects as? [Event] else {
//                return []
//        }
//        return events
//    }
//
//}

extension TBAWebcast: Managed {

    /**
     Insert a Webcast with values from a TBAKit Webcast model in to the managed object context.

     - Important: Method does not manage relationship between Webcast and Event.

     - Parameter model: The TBAKit Webcast representation to set values from.

     - Parameter eventKey: The key for the Event the Webcast belongs to.

     - Parameter context: The NSManagedContext to insert the Webcast in to.

     - Returns: The inserted Webcast.
     */
    public static func insert(_ model: APIWebcast, in context: NSManagedObjectContext) throws -> TBAWebcast {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(TBAWebcast.type), model.type,
                                    #keyPath(TBAWebcast.channel), model.channel)

        return try findOrCreate(in: context, matching: predicate, configure: { (webcast) in
            webcast.type = model.type
            webcast.channel = model.channel
            webcast.date = model.date
            webcast.file = model.file
        })
    }

}

extension TBAWebcast: Orphanable {

    public var isOrphaned: Bool {
        guard let managedObjectContext = managedObjectContext else {
            return hasChanges
        }
        return managedObjectContext.performAndWait { [self] in
            guard let events = events else {
                return true
            }
            return events.count == 0
        }
    }

}
