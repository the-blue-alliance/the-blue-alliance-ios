import Foundation

// Single namespace for all on-device bounded histories (notification
// inbox, activity log, future additions). Owns the directory the
// histories live in plus a factory that wires a `BoundedHistory` to a
// `FileBoundedHistoryStore`.
//
// Mirrors `MyTBALocalStore` so a future "clear all my data" flow can call
// both `MyTBALocalStore.wipeAll()` and `LocalBuffersStore.wipeAll()`.
enum LocalBuffersStore {
    static let directory: URL = {
        let base =
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("tba-buffers", isDirectory: true)
    }()

    static func wipeAll() {
        try? FileManager.default.removeItem(at: directory)
    }

    @MainActor
    static func makeBoundedHistory<Entry: Codable & Identifiable>(
        filename: String,
        configuration: BoundedHistory<Entry>.Configuration,
        compress: Bool = false
    ) -> BoundedHistory<Entry> {
        let store = FileBoundedHistoryStore<Entry>(
            url: directory.appendingPathComponent(filename),
            compress: compress
        )
        let history = BoundedHistory(
            initial: store.load(),
            configuration: configuration,
            didMutate: { store.save($0) }
        )
        // Apply current pruning policy on load (e.g. after a config change
        // tightens maxCount or maxAge between builds).
        history.prune()
        return history
    }
}
