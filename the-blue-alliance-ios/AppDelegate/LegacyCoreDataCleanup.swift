import Foundation

// One-shot removal of the legacy Core Data SQLite store from users upgrading
// from the Core Data era of the app. Safe to call on every launch — the
// `UserDefaults` flag short-circuits after a successful run.
//
// The legacy store lived in an app-group container (see below); older builds
// may instead have written to the app's Application Support directory, so we
// clear both.
enum LegacyCoreDataCleanup {

    private static let storeFilename = "TBA.sqlite"
    private static let completedFlagKey = "has_removed_legacy_core_data_store_v1"

    /// One defaults read on every launch after the first; everything else runs once.
    static func run(
        userDefaults: UserDefaults = .standard,
        storeDirectories: [URL]? = nil
    ) {
        guard !userDefaults.bool(forKey: completedFlagKey) else { return }

        for directory in storeDirectories ?? legacyStoreDirectories() {
            removeStoreFiles(in: directory)
        }
        // Old Refreshable cache key, no longer used.
        userDefaults.removeObject(forKey: "successful_refresh_keys")

        userDefaults.set(true, forKey: completedFlagKey)
    }

    private static func legacyStoreDirectories() -> [URL] {
        var urls: [URL] = []
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppGroup.identifier
        ) {
            urls.append(groupURL)
        }
        urls.append(
            contentsOf: FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )
        )
        return urls
    }

    private static func removeStoreFiles(in directory: URL) {
        let storeURL = directory.appendingPathComponent(storeFilename)
        let sidecarURLs = ["-wal", "-shm"].map {
            directory.appendingPathComponent(storeFilename + $0)
        }
        for url in [storeURL] + sidecarURLs where FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
