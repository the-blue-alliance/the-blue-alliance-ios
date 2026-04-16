import Foundation
import MyTBAKit
import Observation

// Local mirrors of the user's MyTBA favorites and subscriptions. Stored as
// Codable JSON in a single `Application Support/tba-myTBA/` directory so that
// `MyTBALocalStore.wipeAll()` can trivially erase everything if the MyTBA
// API shape ever changes.

enum MyTBALocalStore {
    static let directory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("tba-myTBA", isDirectory: true)
    }()

    static func wipeAll() {
        try? FileManager.default.removeItem(at: directory)
    }
}

@Observable
final class FavoritesStore {

    private(set) var favorites: [MyTBAFavorite]
    @ObservationIgnored private let fileURL: URL

    init(fileURL: URL = MyTBALocalStore.directory.appendingPathComponent("favorites.json")) {
        self.fileURL = fileURL
        self.favorites = (try? Data(contentsOf: fileURL)).flatMap {
            try? JSONDecoder().decode([MyTBAFavorite].self, from: $0)
        } ?? []
    }

    func replaceAll(with favorites: [MyTBAFavorite]) {
        self.favorites = favorites
        try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func clear() {
        favorites = []
        try? FileManager.default.removeItem(at: fileURL)
    }
}

@Observable
final class SubscriptionsStore {

    private(set) var subscriptions: [MyTBASubscription]
    @ObservationIgnored private let fileURL: URL

    init(fileURL: URL = MyTBALocalStore.directory.appendingPathComponent("subscriptions.json")) {
        self.fileURL = fileURL
        self.subscriptions = (try? Data(contentsOf: fileURL)).flatMap {
            try? JSONDecoder().decode([MyTBASubscription].self, from: $0)
        } ?? []
    }

    func replaceAll(with subscriptions: [MyTBASubscription]) {
        self.subscriptions = subscriptions
        try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        guard let data = try? JSONEncoder().encode(subscriptions) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func clear() {
        subscriptions = []
        try? FileManager.default.removeItem(at: fileURL)
    }
}
