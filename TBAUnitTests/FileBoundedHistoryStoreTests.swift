import Foundation
import Testing

@testable import The_Blue_Alliance

struct FileBoundedHistoryStoreTests {

    private struct Stub: Codable, Equatable {
        let id: UUID
        let value: String
    }

    private static func tempURL(filename: String = "buffer.plist") -> URL {
        let base = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
        return base.appendingPathComponent(filename)
    }

    @Test func roundTripUncompressed() throws {
        let url = Self.tempURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let store = FileBoundedHistoryStore<Stub>(url: url, compress: false)
        let entries = [
            Stub(id: UUID(), value: "a"),
            Stub(id: UUID(), value: "b"),
        ]
        store.save(entries)

        let loaded = store.load()
        #expect(loaded == entries)
    }

    @Test func roundTripCompressed() throws {
        let url = Self.tempURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let store = FileBoundedHistoryStore<Stub>(url: url, compress: true)
        let entries = (0..<50).map { Stub(id: UUID(), value: "entry-\($0)") }
        store.save(entries)

        let loaded = store.load()
        #expect(loaded == entries)
    }

    @Test func loadOnMissingFileReturnsEmptyAndDoesNotCreateFile() {
        let url = Self.tempURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let store = FileBoundedHistoryStore<Stub>(url: url)
        let loaded = store.load()

        #expect(loaded.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func loadOnGarbageBytesReturnsEmptyAndDeletesFile() throws {
        let url = Self.tempURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("not a plist".utf8).write(to: url)

        let store = FileBoundedHistoryStore<Stub>(url: url, compress: false)
        let loaded = store.load()

        #expect(loaded.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func loadOnSchemaMismatchReturnsEmptyAndDeletesFile() throws {
        struct OldShape: Codable {
            let totallyDifferentField: Int
        }

        let url = Self.tempURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let oldStore = FileBoundedHistoryStore<OldShape>(url: url, compress: false)
        oldStore.save([OldShape(totallyDifferentField: 42)])
        #expect(FileManager.default.fileExists(atPath: url.path))

        let newStore = FileBoundedHistoryStore<Stub>(url: url, compress: false)
        let loaded = newStore.load()

        #expect(loaded.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func saveCreatesParentDirectoryOnDemand() {
        let url = Self.tempURL(filename: "nested/deeply/buffer.plist")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let store = FileBoundedHistoryStore<Stub>(url: url)
        store.save([Stub(id: UUID(), value: "x")])

        #expect(FileManager.default.fileExists(atPath: url.path))
    }

    @Test func clearRemovesFile() throws {
        let url = Self.tempURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let store = FileBoundedHistoryStore<Stub>(url: url)
        store.save([Stub(id: UUID(), value: "x")])
        #expect(FileManager.default.fileExists(atPath: url.path))

        store.clear()
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func onSchemaErrorFiresOnDecodeFailure() throws {
        let url = Self.tempURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("not a plist".utf8).write(to: url)

        var captured: Error?
        let store = FileBoundedHistoryStore<Stub>(
            url: url,
            compress: false,
            onSchemaError: { captured = $0 }
        )
        _ = store.load()

        #expect(captured != nil)
    }

    @Test func onSchemaErrorDoesNotFireOnMissingFile() {
        let url = Self.tempURL()

        var fired = 0
        let store = FileBoundedHistoryStore<Stub>(
            url: url,
            compress: false,
            onSchemaError: { _ in fired += 1 }
        )
        _ = store.load()

        #expect(fired == 0)
    }
}
