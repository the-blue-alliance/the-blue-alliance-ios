import Foundation
import TBAUtils

enum LocalBuffersStore {

    // Stored in the App Group container so a future Notification Service
    // Extension can write to the same files as the main app.
    static let directory: URL = {
        let base =
            FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: AppGroup.identifier
            )
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("tba-buffers", isDirectory: true)
    }()

    @MainActor private static var registry: [String: BoundedHistoryWipeable] = [:]

    @MainActor
    static func wipeAll() {
        for buffer in registry.values {
            buffer.clearInMemory()
        }
        try? FileManager.default.removeItem(at: directory)
    }

    @MainActor
    static func makeBoundedHistory<Entry: Codable & Identifiable>(
        filename: String,
        configuration: BoundedHistory<Entry>.Configuration,
        compress: Bool = false,
        reporter: (any Reporter)? = nil
    ) -> BoundedHistory<Entry> {
        if let existing = registry[filename] {
            guard let cached = existing as? BoundedHistory<Entry> else {
                preconditionFailure(
                    "BoundedHistory at \(filename) was already created with a different Entry type"
                )
            }
            return cached
        }
        let store = FileBoundedHistoryStore<Entry>(
            url: directory.appendingPathComponent(filename),
            compress: compress,
            onSchemaError: reporter.map { r in { r.record($0) } }
        )
        let history = BoundedHistory(
            initial: store.load(),
            configuration: configuration,
            didMutate: { store.save($0) }
        )
        // Reapply prune in case the config tightened between builds.
        history.prune()
        registry[filename] = history
        return history
    }
}
