import Foundation

// The OpenAPI-generated `AwardType` is a named integer enum without
// `Comparable` conformance — adding it lets callers sort by award type
// without reaching for `.rawValue`.
extension AwardType: Comparable {
    public static func < (lhs: AwardType, rhs: AwardType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
