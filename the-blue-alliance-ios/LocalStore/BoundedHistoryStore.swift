import Foundation

protocol BoundedHistoryStore<Entry> {
    associatedtype Entry: Codable
    func load() -> [Entry]
    func save(_ entries: [Entry])
    func clear()
}

// `load()` swallows any error (missing file, corrupt data, schema
// mismatch from an older build) and returns `[]` so a stale file can't
// crash launch.
struct FileBoundedHistoryStore<Entry: Codable>: BoundedHistoryStore {

    let url: URL
    let compress: Bool

    init(url: URL, compress: Bool = false) {
        self.url = url
        self.compress = compress
    }

    func load() -> [Entry] {
        do {
            let raw = try Data(contentsOf: url)
            let plist =
                compress
                ? try (raw as NSData).decompressed(using: .lzfse) as Data
                : raw
            return try PropertyListDecoder().decode([Entry].self, from: plist)
        } catch {
            try? FileManager.default.removeItem(at: url)
            return []
        }
    }

    func save(_ entries: [Entry]) {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .binary
            let plist = try encoder.encode(entries)
            let payload =
                compress
                ? try (plist as NSData).compressed(using: .lzfse) as Data
                : plist
            try payload.write(to: url, options: .atomic)
        } catch {
            // In-memory state is correct; retry on next mutation.
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}
