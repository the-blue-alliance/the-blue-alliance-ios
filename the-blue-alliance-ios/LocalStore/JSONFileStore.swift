import Foundation

/// Disk operations for one JSON file, run off the main actor in request order so a slow
/// write can't land after a later `delete()`. Encoding stays on the caller's actor: it's
/// microseconds, and it keeps the stored types' default isolation.
final class JSONFileStore<Value: Codable> {

    let url: URL
    private var lastOperation: Task<Void, Never>?

    init(url: URL) {
        self.url = url
    }

    func load() -> Value? {
        (try? Data(contentsOf: url)).flatMap { try? JSONDecoder().decode(Value.self, from: $0) }
    }

    func save(_ value: Value) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        enqueue { [url] in
            try? FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try? data.write(to: url, options: .atomic)
        }
    }

    func delete() {
        enqueue { [url] in
            try? FileManager.default.removeItem(at: url)
        }
    }

    /// For tests that read the file back.
    func flush() async {
        await lastOperation?.value
    }

    private func enqueue(_ operation: @escaping @Sendable () -> Void) {
        let previous = lastOperation
        lastOperation = Task.detached(priority: .utility) {
            await previous?.value
            operation()
        }
    }

}
