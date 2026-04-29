import Foundation
import Observation

// Ring-buffer-like, but with a `maxAge` TTL and random-access removal
// by `Entry.ID` — not a textbook FIFO ring buffer.
@Observable @MainActor
final class BoundedHistory<Entry: Identifiable> {

    struct AgeLimit {
        var maxAge: TimeInterval
        var ageProvider: (Entry) -> Date
    }

    struct Configuration {
        var maxCount: Int
        var ageLimit: AgeLimit?

        init(maxCount: Int) {
            self.maxCount = maxCount
            self.ageLimit = nil
        }

        init(maxCount: Int, maxAge: TimeInterval, ageProvider: @escaping (Entry) -> Date) {
            self.maxCount = maxCount
            self.ageLimit = AgeLimit(maxAge: maxAge, ageProvider: ageProvider)
        }
    }

    private(set) var entries: [Entry]

    @ObservationIgnored private let configuration: Configuration
    @ObservationIgnored private let didMutate: ([Entry]) -> Void

    init(
        initial: [Entry],
        configuration: Configuration,
        didMutate: @escaping ([Entry]) -> Void = { _ in }
    ) {
        self.entries = initial
        self.configuration = configuration
        self.didMutate = didMutate
        prune()
    }

    func append(_ entry: Entry) {
        let beforeCount = entries.count
        entries.insert(entry, at: 0)
        pruneInPlace()
        // Skip didMutate when the insert was immediately pruned out and
        // nothing else changed (e.g. a stale entry past `maxAge`, or an
        // append into a `maxCount: 0` buffer).
        let keptInsert = entries.first?.id == entry.id
        guard keptInsert || entries.count < beforeCount else { return }
        didMutate(entries)
    }

    func remove(id: Entry.ID) {
        let before = entries.count
        entries.removeAll { $0.id == id }
        guard entries.count != before else { return }
        didMutate(entries)
    }

    func clear() {
        guard !entries.isEmpty else { return }
        entries.removeAll()
        didMutate(entries)
    }

    @discardableResult
    func prune() -> Bool {
        let changed = pruneInPlace()
        if changed { didMutate(entries) }
        return changed
    }

    @discardableResult
    private func pruneInPlace() -> Bool {
        let beforeCount = entries.count
        if let ageLimit = configuration.ageLimit {
            let cutoff = Date().addingTimeInterval(-ageLimit.maxAge)
            entries.removeAll { ageLimit.ageProvider($0) < cutoff }
        }
        if entries.count > configuration.maxCount {
            entries = Array(entries.prefix(configuration.maxCount))
        }
        return entries.count != beforeCount
    }
}

// Internal hook for `LocalBuffersStore.wipeAll()`: clears memory without
// invoking the persistence callback.
@MainActor
protocol BoundedHistoryWipeable: AnyObject {
    func clearInMemory()
}

extension BoundedHistory: BoundedHistoryWipeable {
    func clearInMemory() {
        entries.removeAll()
    }
}
