import Foundation
import TBAKit
import CoreData

enum BackgroundFetchError: Error {
    case message(String)
    case error(Error)
}

extension BackgroundFetchError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .message(message: let message):
            // TODO: This, unlike the name says, isn't localized
            return message
        case .error(error: let error):
            return error.localizedDescription
        }
    }
}

// Manage background fetches of information, such as teams (used in a handful of places), events, and matches
class TBABackgroundService {

    // TODO: Combine these in to one method. I tried, but I lost the will to live.
    // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/183

    static func backgroundFetchTeam(_ key: String, in context: NSManagedObjectContext, completion: @escaping (Team?, Error?) -> Void) {
        TBAKit.sharedKit.fetchTeam(key: key) { (modelTeam, error) in
            if let error = error {
                print("Error in background fetch of team \(key) - \(error.localizedDescription)")
                completion(nil, BackgroundFetchError.error(error))
            } else {
                // TODO: Does not handle 304 properly
                if let modelTeam = modelTeam {
                    let team = Team.insert(modelTeam, in: context)
                    context.performSaveOrRollback()

                    completion(team, nil)
                } else {
                    completion(nil, BackgroundFetchError.message("No model for background fetch of team \(key)"))
                }
            }
        }
    }

    static func backgroundFetchEvent(_ key: String, in context: NSManagedObjectContext, completion: @escaping (Event?, Error?) -> Void) {
        TBAKit.sharedKit.fetchEvent(key: key) { (modelEvent, error) in
            if let error = error {
                print("Error in background fetch of event \(key) - \(error.localizedDescription)")
                completion(nil, BackgroundFetchError.error(error))
            } else {
                guard let modelEvent = modelEvent else {
                    completion(nil, BackgroundFetchError.message("No model for background fetch of event \(key)"))
                    return
                }

                let event = Event.insert(with: modelEvent, in: context)
                context.performSaveOrRollback()

                completion(event, nil)
            }
        }
    }

    static func backgroundFetchMatch(_ key: String, in context: NSManagedObjectContext, completion: @escaping (Match?, Error?) -> Void) {
        // TODO: We could make this easier by removing the relationship between Match <-> Event as being non-optional
        // However, we'd have to make sure that matches that got inserted in the BG didn't get double inserted, and got
        // resolved and added to their respective events later. There are places that use event information on a Match
        // though, so we'd have to remove those. This is for sure a decoupling that requires some though.
        let event = Event.findOrFetch(in: context, matching: NSPredicate(format: "%K == %@", #keyPath(Event.key), key))
        if event == nil {
            guard let eventKeySubstring = key.split(separator: "_").first else {
                completion(nil, BackgroundFetchError.message("Unable to get Event for match \(key)"))
                return
            }
            backgroundFetchEvent(String(eventKeySubstring), in: context) { (event, error) in
                if let error = error {
                    print("Error in background fetch of match \(key) - \(error.localizedDescription)")
                    completion(nil, BackgroundFetchError.error(error))
                } else {
                    guard let event = event else {
                        completion(nil, BackgroundFetchError.message("No event for background fetch of match \(key)"))
                        return
                    }
                    backgroundFetchMatch(key, for: event, in: context, completion: completion)
                }
            }
        } else {
            backgroundFetchMatch(key, for: event!, in: context, completion: completion)
        }
    }

    private static func backgroundFetchMatch(_ key: String, for event: Event, in context: NSManagedObjectContext, completion: @escaping (Match?, Error?) -> Void) {
        TBAKit.sharedKit.fetchMatch(key: key) { (modelMatch, error) in
            if let error = error {
                print("Error in background fetch of match \(key) - \(error.localizedDescription)")
                completion(nil, BackgroundFetchError.error(error))
            } else {
                // TODO: This logic doesn't seem right - it seems like we'll return an error for a 304, which isn't
                // great, but also I'm planning on killing (or reworking) this background service
                if let modelMatch = modelMatch {
                    let match = Match.insert(modelMatch, event: event, in: context)
                    context.performSaveOrRollback()

                    completion(match, nil)
                } else {
                    completion(nil, BackgroundFetchError.message("No model for background fetch of match \(key)"))
                }
            }
        }
    }

}
