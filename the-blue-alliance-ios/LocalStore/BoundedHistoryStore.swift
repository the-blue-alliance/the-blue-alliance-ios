import Foundation

protocol BoundedHistoryStore<Entry> {
    associatedtype Entry: Codable
    func load() -> [Entry]
    func save(_ entries: [Entry])
    func clear()
}

private enum FileBoundedHistoryCoders {
    static let encoder: PropertyListEncoder = {
        let e = PropertyListEncoder()
        e.outputFormat = .binary
        return e
    }()
    static let decoder = PropertyListDecoder()
}

struct FileBoundedHistoryStore<Entry: Codable>: BoundedHistoryStore {

    let url: URL
    let compress: Bool
    let protection: FileProtectionType?
    let onSchemaError: ((Error) -> Void)?

    init(
        url: URL,
        compress: Bool = false,
        protection: FileProtectionType? = .completeUntilFirstUserAuthentication,
        onSchemaError: ((Error) -> Void)? = nil
    ) {
        self.url = url
        self.compress = compress
        self.protection = protection
        self.onSchemaError = onSchemaError
    }

    // Format errors (decompress, decode) wipe the file; read errors don't —
    // the file might be valid and the read transient.
    func load() -> [Entry] {
        let raw: Data
        do {
            raw = try Data(contentsOf: url)
        } catch {
            return []
        }
        let plist: Data
        do {
            plist =
                compress
                ? try (raw as NSData).decompressed(using: .lzfse) as Data
                : raw
        } catch {
            onSchemaError?(error)
            try? FileManager.default.removeItem(at: url)
            return []
        }
        do {
            return try FileBoundedHistoryCoders.decoder.decode([Entry].self, from: plist)
        } catch {
            onSchemaError?(error)
            try? FileManager.default.removeItem(at: url)
            return []
        }
    }

    func save(_ entries: [Entry]) {
        let plist: Data
        do {
            plist = try FileBoundedHistoryCoders.encoder.encode(entries)
        } catch {
            onSchemaError?(error)
            return
        }
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let payload =
                compress
                ? try (plist as NSData).compressed(using: .lzfse) as Data
                : plist
            try payload.write(to: url, options: .atomic)
            if let protection {
                try? FileManager.default.setAttributes(
                    [.protectionKey: protection],
                    ofItemAtPath: url.path
                )
            }
        } catch {
            // In-memory state is correct; retry on next mutation.
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}
