import FirebaseDatabase
import Foundation

@objc protocol FMSStatusSubscribable {
    var realtimeDatabaseService: RealtimeDatabaseService { get }

    func fmsStatusChanged(isDatafeedDown: Bool)
}

extension FMSStatusSubscribable {
    func registerForFMSStatusChanges() {
        realtimeDatabaseService.registerForFMSStatusChanges(self)
    }
}

@objc protocol EventStatusSubscribable {
    var realtimeDatabaseService: RealtimeDatabaseService { get }

    func eventStatusChanged(isEventOffline: Bool)
}

extension EventStatusSubscribable {
    func registerForEventStatusChanges(eventKey: String) {
        realtimeDatabaseService.registerForEventStatusChanges(self, eventKey: eventKey)
    }
}

class RealtimeDatabaseService: NSObject {

    private(set) var isDatafeedDown: Bool = false
    private(set) var downEvents: [String] = []

    private let databaseReference: DatabaseReference

    private let fmsStatusSubscribers: NSHashTable<FMSStatusSubscribable> = NSHashTable.weakObjects()
    private let eventStatusSubscribers: NSMapTable<NSString, NSHashTable<EventStatusSubscribable>> = NSMapTable()

    init(databaseReference: DatabaseReference) {
        self.databaseReference = databaseReference

        super.init()

        _ = databaseReference.child("is_datafeed_down").observe(.value) { [unowned self] (snapshot) in
            guard let isDatafeedDown = snapshot.value as? Bool else {
                return
            }
            self.isDatafeedDown = isDatafeedDown
            self.updateFMSSubscribers(isDatafeedDown: isDatafeedDown)
        }

        let downEventsDatabaseReference = databaseReference.child("down_events")
        downEventsDatabaseReference.observe(.value) { [unowned self] (snapshot) in
            guard let downEvents = snapshot.value as? [String] else {
                return
            }
            self.downEvents = downEvents
        }
        downEventsDatabaseReference.observe(.childAdded) { [unowned self] (snapshot) in
            guard let eventKey = snapshot.value as? String else {
                return
            }
            self.updateEventSubscribers(eventKey: eventKey, isEventOffline: true)
        }
        downEventsDatabaseReference.observe(.childRemoved) { [unowned self] (snapshot) in
            guard let eventKey = snapshot.value as? String else {
                return
            }
            self.updateEventSubscribers(eventKey: eventKey, isEventOffline: false)
        }
    }

    // MARK: - Internal
    // These should be private, but we need to expose them for testing

    func registerForFMSStatusChanges(_ subscriber: FMSStatusSubscribable) {
        fmsStatusSubscribers.add(subscriber)
    }

    func registerForEventStatusChanges(_ subscriber: EventStatusSubscribable, eventKey: String) {
        let subscribers = eventStatusSubscribers.object(forKey: eventKey as NSString) ?? NSHashTable.weakObjects()
        subscribers.add(subscriber)
        eventStatusSubscribers.setObject(subscribers, forKey: eventKey as NSString)
    }

    func updateFMSSubscribers(isDatafeedDown: Bool) {
        for subscriber in self.fmsStatusSubscribers.allObjects {
            subscriber.fmsStatusChanged(isDatafeedDown: isDatafeedDown)
        }
    }

    func updateEventSubscribers(eventKey: String, isEventOffline: Bool) {
        guard let subscribersTable = eventStatusSubscribers.object(forKey: eventKey as NSString) else {
            return
        }
        for subscriber in subscribersTable.allObjects {
            subscriber.eventStatusChanged(isEventOffline: isEventOffline)
        }
    }

}
