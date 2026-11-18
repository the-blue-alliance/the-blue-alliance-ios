import Foundation
import MyTBAKit
import Observation

// Local mirrors of the user's MyTBA favorites and subscriptions. Stored as
// Codable JSON in a single `Application Support/tba-myTBA/` directory so that
// `MyTBALocalStore.wipeAll()` can trivially erase everything if the MyTBA
// API shape ever changes. Both are keyed by model: the server can hold the same
// favorite or subscription twice, and a repeated row crashes the myTBA list's
// diffable snapshot.

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

// Passed explicitly to the handful of view controllers that care about myTBA
// state. Kept out of `Dependencies` since only myTBA-adjacent screens use it.
struct MyTBAStores {
    let favorites: FavoritesStore
    let subscriptions: SubscriptionsStore
}

@Observable
final class FavoritesStore {

    private var byID: [MyTBAModelID: MyTBAFavorite]
    @ObservationIgnored private let file: JSONFileStore<[MyTBAFavorite]>

    var favorites: [MyTBAFavorite] { Array(byID.values) }

    init(fileURL: URL = MyTBALocalStore.directory.appendingPathComponent("favorites.json")) {
        self.file = JSONFileStore(url: fileURL)
        self.byID = Dictionary((file.load() ?? []).map { ($0.id, $0) }) { first, _ in first }
    }

    func replaceAll(with favorites: [MyTBAFavorite]) {
        byID = Dictionary(favorites.map { ($0.id, $0) }) { first, _ in first }
        persist()
    }

    func upsert(_ favorite: MyTBAFavorite) {
        byID[favorite.id] = favorite
        persist()
    }

    func remove(_ model: some MyTBAModelIdentifiable) {
        byID[model.myTBAModelID] = nil
        persist()
    }

    func contains(_ model: some MyTBAModelIdentifiable) -> Bool {
        byID[model.myTBAModelID] != nil
    }

    func clear() {
        byID = [:]
        file.delete()
    }

    func favoriteTeamKeys() -> [String] {
        byID.keys.filter { $0.modelType == .team }.map(\.modelKey).sorted()
    }

    func flush() async {
        await file.flush()
    }

    private func persist() {
        file.save(favorites)
    }
}

@Observable
final class SubscriptionsStore {

    private var byID: [MyTBAModelID: MyTBASubscription]
    @ObservationIgnored private let file: JSONFileStore<[MyTBASubscription]>

    var subscriptions: [MyTBASubscription] { Array(byID.values) }

    init(fileURL: URL = MyTBALocalStore.directory.appendingPathComponent("subscriptions.json")) {
        self.file = JSONFileStore(url: fileURL)
        self.byID = Dictionary((file.load() ?? []).map { ($0.id, $0) }) { first, _ in first }
    }

    func replaceAll(with subscriptions: [MyTBASubscription]) {
        byID = Dictionary(subscriptions.map { ($0.id, $0) }) { first, _ in first }
        persist()
    }

    func upsert(_ subscription: MyTBASubscription) {
        byID[subscription.id] = subscription
        persist()
    }

    func remove(_ model: some MyTBAModelIdentifiable) {
        byID[model.myTBAModelID] = nil
        persist()
    }

    func clear() {
        byID = [:]
        file.delete()
    }

    func subscription(for model: some MyTBAModelIdentifiable) -> MyTBASubscription? {
        byID[model.myTBAModelID]
    }

    func flush() async {
        await file.flush()
    }

    private func persist() {
        file.save(subscriptions)
    }
}
