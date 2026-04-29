import Foundation
import TBAUtils

enum LocalBuffersStore {

    // Stored in the App Group container so a future Notification Service
    // Extension can write to the same files as the main app. A nil
    // container indicates a misconfigured entitlement — fail loudly
    // rather than silently fall back somewhere the extension can't see.
    static let directory: URL = {
        guard
            let base = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: AppGroup.identifier
            )
        else {
            fatalError(
                "App group container \(AppGroup.identifier) is unavailable; check the entitlements file."
            )
        }
        return base.appendingPathComponent("tba-buffers", isDirectory: true)
    }()

    // Weak refs so callers control buffer lifetime; the registry exists
    // for dedup + wipeAll, not as a retainer.
    private struct WeakBuffer {
        weak var value: AnyObject?
    }

    @MainActor private static var registry: [String: WeakBuffer] = [:]

    @MainActor
    static func wipeAll() {
        try? FileManager.default.removeItem(at: directory)
        for entry in registry.values {
            (entry.value as? BoundedHistoryWipeable)?.clearInMemory()
        }
        registry.removeAll()
    }

    @MainActor
    static func makeBoundedHistory<Entry: Codable & Identifiable>(
        filename: String,
        configuration: BoundedHistory<Entry>.Configuration,
        compress: Bool = false,
        reporter: (any Reporter)? = nil
    ) -> BoundedHistory<Entry> {
        if let existing = registry[filename]?.value {
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
            onSchemaError: reporter.map { reporter in { reporter.record($0) } }
        )
        let history = BoundedHistory(
            initial: store.load(),
            configuration: configuration,
            didMutate: { store.save($0) }
        )
        registry[filename] = WeakBuffer(value: history)
        return history
    }
}
