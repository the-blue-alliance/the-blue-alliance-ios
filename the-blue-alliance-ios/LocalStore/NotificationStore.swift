import Foundation

final class NotificationStore {

    struct Entry: Codable, Identifiable, Equatable {
        let id: UUID
        let receivedAt: Date
        let title: String
        let body: String
        let payload: PushNotificationPayload
    }

    static let maxCount = 100

    private(set) var entries: [Entry]
    private let file: JSONFileStore<[Entry]>

    init(directory: URL = NotificationStore.defaultDirectory) {
        self.file = JSONFileStore(url: directory.appendingPathComponent("notifications.json"))
        let loaded = file.load() ?? []
        self.entries = Array(loaded.prefix(Self.maxCount))
        if loaded.count > Self.maxCount {
            persist()
        }
    }

    func append(_ entry: Entry) {
        entries.insert(entry, at: 0)
        if entries.count > Self.maxCount {
            entries = Array(entries.prefix(Self.maxCount))
        }
        persist()
    }

    func remove(id: UUID) {
        let before = entries.count
        entries.removeAll { $0.id == id }
        guard entries.count != before else { return }
        persist()
    }

    func clear() {
        entries.removeAll()
        file.delete()
    }

    func flush() async {
        await file.flush()
    }

    private func persist() {
        file.save(entries)
    }

    nonisolated private static var defaultDirectory: URL {
        guard
            let base = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: AppGroup.identifier
            )
        else {
            fatalError(
                "App group container \(AppGroup.identifier) is unavailable; check the entitlements file."
            )
        }
        return base
    }
}
