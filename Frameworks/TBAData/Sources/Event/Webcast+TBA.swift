import Foundation

extension Webcast: Managed {

    public var isOrphaned: Bool {
        return events.count == 0
    }

}
