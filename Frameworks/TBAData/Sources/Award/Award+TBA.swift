import Foundation

extension Award: Managed {

    public var isOrphaned: Bool {
        return event == nil
    }

}
