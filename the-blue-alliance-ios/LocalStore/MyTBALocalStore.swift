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

typealias FavoritesStore = MyTBAModelStore<MyTBAFavorite>
typealias SubscriptionsStore = MyTBAModelStore<MyTBASubscription>

@Observable
final class MyTBAModelStore<Model: MyTBAModel> {

    private var byID: [MyTBAModelID: Model]
    @ObservationIgnored private let file: JSONFileStore<[Model]>

    private var models: [Model] { Array(byID.values) }

    static var defaultFileURL: URL {
        MyTBALocalStore.directory.appendingPathComponent("\(Model.arrayKey).json")
    }

    init(fileURL: URL = MyTBAModelStore.defaultFileURL) {
        self.file = JSONFileStore(url: fileURL)
        self.byID = Dictionary((file.load() ?? []).map { ($0.id, $0) }) { first, _ in first }
    }

    func replaceAll(with models: [Model]) {
        byID = Dictionary(models.map { ($0.id, $0) }) { first, _ in first }
        persist()
    }

    func upsert(_ model: Model) {
        byID[model.id] = model
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

    func flush() async {
        await file.flush()
    }

    private func persist() {
        file.save(models)
    }
}

extension MyTBAModelStore where Model == MyTBAFavorite {
    var favorites: [MyTBAFavorite] { models }

    func favoriteTeamKeys() -> [String] {
        byID.keys.filter { $0.modelType == .team }.map(\.modelKey).sorted()
    }
}

extension MyTBAModelStore where Model == MyTBASubscription {
    var subscriptions: [MyTBASubscription] { models }

    func subscription(for model: some MyTBAModelIdentifiable) -> MyTBASubscription? {
        byID[model.myTBAModelID]
    }
}
