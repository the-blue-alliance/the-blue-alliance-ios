import Foundation
import Testing

@testable import The_Blue_Alliance

@MainActor
struct NotificationStoreTests {

    private static func tempDirectory() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    private static func entry(
        title: String = "Title",
        body: String = "Body",
        receivedAt: Date = Date()
    ) -> NotificationStore.Entry {
        NotificationStore.Entry(
            id: UUID(),
            receivedAt: receivedAt,
            title: title,
            body: body,
            payload: .match(
                kind: .score,
                matchKey: "2025micmp4_f1m2",
                eventKey: "2025micmp4",
                teamKey: "frc2337"
            )
        )
    }

    @Test func appendPrependsNewest() {
        let dir = Self.tempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = NotificationStore(directory: dir)

        let first = Self.entry(title: "First")
        let second = Self.entry(title: "Second")
        store.append(first)
        store.append(second)

        #expect(store.entries.map(\.title) == ["Second", "First"])
    }

    @Test func appendPastMaxCountEvictsOldest() {
        let dir = Self.tempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = NotificationStore(directory: dir)

        for index in 0..<(NotificationStore.maxCount + 5) {
            store.append(Self.entry(title: "n\(index)"))
        }

        #expect(store.entries.count == NotificationStore.maxCount)
        #expect(store.entries.first?.title == "n\(NotificationStore.maxCount + 4)")
        #expect(store.entries.last?.title == "n5")
    }

    @Test func removeByIDDropsEntry() {
        let dir = Self.tempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = NotificationStore(directory: dir)
        let target = Self.entry(title: "target")
        let other = Self.entry(title: "other")
        store.append(target)
        store.append(other)

        store.remove(id: target.id)

        #expect(store.entries.map(\.id) == [other.id])
    }

    @Test func clearEmptiesEntriesAndRemovesFile() {
        let dir = Self.tempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = NotificationStore(directory: dir)
        store.append(Self.entry())

        let url = dir.appendingPathComponent("notifications.json")
        #expect(FileManager.default.fileExists(atPath: url.path))

        store.clear()

        #expect(store.entries.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func loadFromMissingFileReturnsEmpty() {
        let dir = Self.tempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = NotificationStore(directory: dir)

        #expect(store.entries.isEmpty)
    }

    @Test func loadFromCorruptFileReturnsEmpty() throws {
        let dir = Self.tempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try Data("not json".utf8).write(
            to: dir.appendingPathComponent("notifications.json")
        )

        let store = NotificationStore(directory: dir)

        #expect(store.entries.isEmpty)
    }

    @Test func persistsAcrossInstances() {
        let dir = Self.tempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let writer = NotificationStore(directory: dir)
        let entry = Self.entry(title: "persisted")
        writer.append(entry)

        let reader = NotificationStore(directory: dir)
        #expect(reader.entries == [entry])
    }

    @Test func mutationsPostNotificationCenterChange() async {
        let dir = Self.tempDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = NotificationStore(directory: dir)

        var observed = 0
        let token = NotificationCenter.default.addObserver(
            forName: .notificationStoreDidChange,
            object: store,
            queue: .main
        ) { _ in observed += 1 }
        defer { NotificationCenter.default.removeObserver(token) }

        store.append(Self.entry())
        store.remove(id: store.entries[0].id)
        store.append(Self.entry())
        store.clear()

        // The observer block runs on the main queue; yield once so it drains.
        await Task.yield()

        #expect(observed == 4)
    }
}
