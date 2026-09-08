import Foundation
import MyTBAKit
import Observation

// Local mirrors of the user's MyTBA favorites and subscriptions. Stored as
// Codable JSON in a single `Application Support/tba-myTBA/` directory so that
// `MyTBALocalStore.wipeAll()` can trivially erase everything if the MyTBA
// API shape ever changes.

enum MyTBALocalStore {
    static let directory: URL = {
        let base =
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("tba-myTBA", isDirectory: true)
    }()

    static func wipeAll() {
        try? FileManager.default.removeItem(at: directory)
    }
}

extension Notification.Name {
    static let favoritesStoreDidChange = Notification.Name("favoritesStoreDidChange")
    static let subscriptionsStoreDidChange = Notification.Name("subscriptionsStoreDidChange")
}

// Passed explicitly to the handful of view controllers that care about myTBA
// state. Kept out of `Dependencies` since only myTBA-adjacent screens use it.
struct MyTBAStores {
    let favorites: FavoritesStore
    let subscriptions: SubscriptionsStore
}

@Observable
final class FavoritesStore {

    private(set) var favorites: [MyTBAFavorite]
    @ObservationIgnored private let file: JSONFileStore<[MyTBAFavorite]>

    init(fileURL: URL = MyTBALocalStore.directory.appendingPathComponent("favorites.json")) {
        self.file = JSONFileStore(url: fileURL)
        self.favorites = file.load() ?? []
    }

    func replaceAll(with favorites: [MyTBAFavorite]) {
        self.favorites = favorites
        persist()
    }

    func upsert(_ favorite: MyTBAFavorite) {
        var copy = favorites.filter {
            !($0.modelKey == favorite.modelKey && $0.modelType == favorite.modelType)
        }
        copy.append(favorite)
        favorites = copy
        persist()
    }

    func remove(modelKey: String, modelType: MyTBAModelType) {
        favorites = favorites.filter { !($0.modelKey == modelKey && $0.modelType == modelType) }
        persist()
    }

    func clear() {
        favorites = []
        file.delete()
        NotificationCenter.default.post(name: .favoritesStoreDidChange, object: self)
    }

    func favoriteTeamKeys() -> [String] {
        favorites.filter { $0.modelType == .team }.map { $0.modelKey }
    }

    /// Waits for pending disk writes; for tests that read the file back.
    func flush() async {
        await file.flush()
    }

    private func persist() {
        file.save(favorites)
        NotificationCenter.default.post(name: .favoritesStoreDidChange, object: self)
    }
}

@Observable
final class SubscriptionsStore {

    private(set) var subscriptions: [MyTBASubscription]
    @ObservationIgnored private let file: JSONFileStore<[MyTBASubscription]>

    init(fileURL: URL = MyTBALocalStore.directory.appendingPathComponent("subscriptions.json")) {
        self.file = JSONFileStore(url: fileURL)
        self.subscriptions = file.load() ?? []
    }

    func replaceAll(with subscriptions: [MyTBASubscription]) {
        self.subscriptions = subscriptions
        persist()
    }

    func upsert(_ subscription: MyTBASubscription) {
        var copy = subscriptions.filter {
            !($0.modelKey == subscription.modelKey && $0.modelType == subscription.modelType)
        }
        copy.append(subscription)
        subscriptions = copy
        persist()
    }

    func remove(modelKey: String, modelType: MyTBAModelType) {
        subscriptions = subscriptions.filter {
            !($0.modelKey == modelKey && $0.modelType == modelType)
        }
        persist()
    }

    func clear() {
        subscriptions = []
        file.delete()
        NotificationCenter.default.post(name: .subscriptionsStoreDidChange, object: self)
    }

    func subscription(modelKey: String, modelType: MyTBAModelType) -> MyTBASubscription? {
        subscriptions.first { $0.modelKey == modelKey && $0.modelType == modelType }
    }

    /// Waits for pending disk writes; for tests that read the file back.
    func flush() async {
        await file.flush()
    }

    private func persist() {
        file.save(subscriptions)
        NotificationCenter.default.post(name: .subscriptionsStoreDidChange, object: self)
    }
}
