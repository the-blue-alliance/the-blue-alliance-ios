import Foundation

// Persistence backend for a `BoundedHistory`. Knows nothing about
// eviction semantics — it just loads, saves, and clears a `[Entry]` for
// a single storage location.
protocol BoundedHistoryStore<Entry> {
    associatedtype Entry: Codable
    func load() -> [Entry]
    func save(_ entries: [Entry])
    func clear()
}

// Binary-plist file with optional LZFSE compression.
//
// `load()` is resilient: any failure (missing file, corrupt data,
// decompress/decode failure, schema mismatch from an older build) wipes
// the file and returns `[]` rather than throwing.
//
// `save(_:)` creates the parent directory on demand, so the first write
// after a fresh install or a `clear()` just works.
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
            // Best-effort: keep in-memory state, retry on next mutation.
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}
