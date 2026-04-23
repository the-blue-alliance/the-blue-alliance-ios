import Foundation

// The OpenAPI-generated `EventType` is a named integer enum without
// `Comparable` conformance — adding it lets callers sort by event type
// without reaching for `.rawValue`.
extension EventType: Comparable {
    public static func < (lhs: EventType, rhs: EventType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
