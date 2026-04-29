import Foundation
import Testing

@testable import The_Blue_Alliance

@MainActor
struct BoundedHistoryTests {

    private struct Stub: Codable, Identifiable, Equatable {
        let id: UUID
        let timestamp: Date
        init(at timestamp: Date = Date()) {
            self.id = UUID()
            self.timestamp = timestamp
        }
    }

    private static func config(maxCount: Int = 10) -> BoundedHistory<Stub>.Configuration {
        .init(maxCount: maxCount)
    }

    private static func ageConfig(
        maxCount: Int = 10,
        maxAge: TimeInterval
    ) -> BoundedHistory<Stub>.Configuration {
        .init(maxCount: maxCount, maxAge: maxAge, ageProvider: \.timestamp)
    }

    @Test func appendPrependsAndFiresMutate() {
        var fired: [[Stub]] = []
        let buffer = BoundedHistory<Stub>(
            initial: [],
            configuration: Self.config(),
            didMutate: { fired.append($0) }
        )

        let first = Stub()
        let second = Stub()
        buffer.append(first)
        buffer.append(second)

        #expect(buffer.entries.map(\.id) == [second.id, first.id])
        #expect(fired.count == 2)
        #expect(fired.last?.first?.id == second.id)
    }

    @Test func appendPastMaxCountEvictsOldest() {
        let buffer = BoundedHistory<Stub>(initial: [], configuration: Self.config(maxCount: 3))
        let entries = (0..<5).map { _ in Stub() }
        for entry in entries { buffer.append(entry) }

        #expect(buffer.entries.count == 3)
        #expect(buffer.entries.map(\.id) == [entries[4].id, entries[3].id, entries[2].id])
    }

    @Test func appendPastMaxAgePrunesExpired() {
        let now = Date()
        let stale = Stub(at: now.addingTimeInterval(-3600))
        let fresh = Stub(at: now)
        let buffer = BoundedHistory<Stub>(
            initial: [stale],
            configuration: Self.ageConfig(maxAge: 60)
        )
        buffer.append(fresh)

        #expect(buffer.entries.map(\.id) == [fresh.id])
    }

    @Test func removeMatchingFires() {
        var fired = 0
        let target = Stub()
        let other = Stub()
        let buffer = BoundedHistory<Stub>(
            initial: [target, other],
            configuration: Self.config(),
            didMutate: { _ in fired += 1 }
        )

        buffer.remove(id: target.id)

        #expect(buffer.entries.map(\.id) == [other.id])
        #expect(fired == 1)
    }

    @Test func removeMissingDoesNotFire() {
        var fired = 0
        let buffer = BoundedHistory<Stub>(
            initial: [Stub()],
            configuration: Self.config(),
            didMutate: { _ in fired += 1 }
        )
        buffer.remove(id: UUID())
        #expect(fired == 0)
    }

    @Test func clearOnEmptyDoesNotFire() {
        var fired = 0
        let buffer = BoundedHistory<Stub>(
            initial: [],
            configuration: Self.config(),
            didMutate: { _ in fired += 1 }
        )
        buffer.clear()
        #expect(fired == 0)
    }

    @Test func clearOnPopulatedFiresOnce() {
        var fired = 0
        let buffer = BoundedHistory<Stub>(
            initial: [Stub(), Stub()],
            configuration: Self.config(),
            didMutate: { _ in fired += 1 }
        )
        buffer.clear()
        #expect(buffer.entries.isEmpty)
        #expect(fired == 1)
    }

    @Test func pruneReturnsTrueWhenChangedAndFires() {
        var fired = 0
        let stale = Stub(at: Date().addingTimeInterval(-3600))
        let fresh = Stub()
        let buffer = BoundedHistory<Stub>(
            initial: [fresh, stale],
            configuration: Self.ageConfig(maxAge: 60),
            didMutate: { _ in fired += 1 }
        )

        let changed = buffer.prune()

        #expect(changed)
        #expect(buffer.entries.map(\.id) == [fresh.id])
        #expect(fired == 1)
    }

    @Test func pruneReturnsFalseWhenUnchanged() {
        var fired = 0
        let buffer = BoundedHistory<Stub>(
            initial: [Stub()],
            configuration: Self.config(),
            didMutate: { _ in fired += 1 }
        )
        let changed = buffer.prune()
        #expect(!changed)
        #expect(fired == 0)
    }

    @Test func clearInMemoryDoesNotFireMutate() {
        var fired = 0
        let buffer = BoundedHistory<Stub>(
            initial: [Stub(), Stub()],
            configuration: Self.config(),
            didMutate: { _ in fired += 1 }
        )
        buffer.clearInMemory()
        #expect(buffer.entries.isEmpty)
        #expect(fired == 0)
    }
}
