import Foundation

@MainActor
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
    private let url: URL

    init(directory: URL = NotificationStore.defaultDirectory) {
        self.url = directory.appendingPathComponent("notifications.json")
        self.entries =
            (try? Data(contentsOf: url))
            .flatMap { try? JSONDecoder().decode([Entry].self, from: $0) } ?? []
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
        guard !entries.isEmpty else { return }
        entries.removeAll()
        try? FileManager.default.removeItem(at: url)
        notifyChange()
    }

    private func persist() {
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: url, options: .atomic)
        }
        notifyChange()
    }

    private func notifyChange() {
        NotificationCenter.default.post(name: .notificationStoreDidChange, object: self)
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

extension Notification.Name {
    static let notificationStoreDidChange = Notification.Name("notificationStoreDidChange")
}
