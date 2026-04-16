import Foundation

// One-shot removal of the legacy Core Data SQLite store from users upgrading
// from the Core Data era of the app. Safe to call on every launch — the
// `UserDefaults` flag short-circuits after a successful run.
//
// The legacy store lived in an app-group container (see below); older builds
// may instead have written to the app's Application Support directory, so we
// clear both.
enum LegacyCoreDataCleanup {

    private static let appGroupIdentifier = "group.com.the-blue-alliance.tba.tbadata"
    private static let storeFilename = "TBA.sqlite"
    private static let completedFlagKey = "has_removed_legacy_core_data_store_v1"

    static func run(userDefaults: UserDefaults = .standard,
                    fileManager: FileManager = .default) {
        guard !userDefaults.bool(forKey: completedFlagKey) else { return }

        for baseURL in legacyStoreBaseURLs(fileManager: fileManager) {
            removeStoreFiles(at: baseURL, fileManager: fileManager)
        }

        userDefaults.set(true, forKey: completedFlagKey)
    }

    private static func legacyStoreBaseURLs(fileManager: FileManager) -> [URL] {
        var urls: [URL] = []
        if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            urls.append(groupURL)
        }
        urls.append(contentsOf: fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask))
        return urls
    }

    private static func removeStoreFiles(at baseURL: URL, fileManager: FileManager) {
        let storeURL = baseURL.appendingPathComponent(storeFilename)
        let sidecarURLs = ["-wal", "-shm"].map { baseURL.appendingPathComponent(storeFilename + $0) }
        for url in [storeURL] + sidecarURLs where fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
}
