import Foundation

extension MatchAlliance: Managed {

    public var isOrphaned: Bool {
        return match == nil
    }

}
