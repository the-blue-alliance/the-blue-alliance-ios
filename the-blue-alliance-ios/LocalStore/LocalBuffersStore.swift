import Foundation

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
        // Reapply prune in case the config tightened between builds.
        history.prune()
        return history
    }
}
