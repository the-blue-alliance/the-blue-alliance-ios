import Foundation
import Testing

@testable import The_Blue_Alliance

struct LegacyCoreDataCleanupTests {

    private static func tempDirectory() throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    @Test func removesTheStoreAndItsSidecarsOnce() throws {
        let directory = try Self.tempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        defaults.set(["x"], forKey: "successful_refresh_keys")
        let files = ["TBA.sqlite", "TBA.sqlite-wal", "TBA.sqlite-shm"].map {
            directory.appendingPathComponent($0)
        }
        for file in files { try Data().write(to: file) }

        LegacyCoreDataCleanup.run(userDefaults: defaults, storeDirectories: [directory])

        #expect(files.allSatisfy { !FileManager.default.fileExists(atPath: $0.path) })
        #expect(defaults.object(forKey: "successful_refresh_keys") == nil)

        // A second run is a no-op: a store that reappears is left alone.
        try Data().write(to: files[0])
        LegacyCoreDataCleanup.run(userDefaults: defaults, storeDirectories: [directory])
        #expect(FileManager.default.fileExists(atPath: files[0].path))
    }

}
