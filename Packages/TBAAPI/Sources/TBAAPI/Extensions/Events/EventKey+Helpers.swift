import Foundation

extension EventKey {
    // Year prefix of an event key (`2024nyro` → 2024). nil for malformed keys.
    public var year: Int? {
        Int(prefix(4))
    }

    // Event code stripped of its 4-digit year prefix (`2024nyro` → `nyro`).
    public var eventCode: String {
        String(dropFirst(4))
    }
}
