import Foundation
import Observation

// Ring-buffer-like, but with a `maxAge` TTL and random-access removal
// by `Entry.ID` — not a textbook FIFO ring buffer.
@Observable @MainActor
final class BoundedHistory<Entry: Identifiable> {

    struct Configuration {
        var maxCount: Int
        var maxAge: TimeInterval?
        var ageProvider: (Entry) -> Date

        init(
            maxCount: Int,
            maxAge: TimeInterval? = nil,
            ageProvider: @escaping (Entry) -> Date
        ) {
            self.maxCount = maxCount
            self.maxAge = maxAge
            self.ageProvider = ageProvider
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
    }

    func append(_ entry: Entry) {
        entries.insert(entry, at: 0)
        _ = pruneInPlace()
        didMutate(entries)
    }

    func remove(id: Entry.ID) {
        let before = entries.count
        entries.removeAll { $0.id == id }
        guard entries.count != before else { return }
        didMutate(entries)
    }

    func clear() {
        guard !entries.isEmpty else {
            didMutate([])
            return
        }
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
        if let maxAge = configuration.maxAge {
            let cutoff = Date().addingTimeInterval(-maxAge)
            entries.removeAll { configuration.ageProvider($0) < cutoff }
        }
        if entries.count > configuration.maxCount {
            entries = Array(entries.prefix(configuration.maxCount))
        }
        return entries.count != beforeCount
    }
}
