import Foundation

/// One JSON file's disk operations, run off the main actor in the order they were
/// requested, so a slow write can never land after a later `delete()` and resurrect the
/// file. Encoding happens on the caller's actor - it's microseconds for these payloads,
/// and it means the stored types keep their default isolation. Loading stays synchronous:
/// the stores read once at init and callers read the in-memory value.
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

    /// Completes once every operation requested so far has finished. Tests call this
    /// before reading the file back.
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
