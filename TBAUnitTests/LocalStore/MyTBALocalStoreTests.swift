import Foundation
import MyTBAKit
import Testing

@testable import The_Blue_Alliance

@MainActor
struct MyTBALocalStoreTests {

    private let directory = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(UUID().uuidString, isDirectory: true)

    private var favoritesURL: URL { directory.appendingPathComponent("favorites.json") }
    private var subscriptionsURL: URL { directory.appendingPathComponent("subscriptions.json") }

    private let eventID = MyTBAModelID(modelType: .event, modelKey: "2026miket")
    private let teamID = MyTBAModelID(modelType: .team, modelKey: "frc7332")

    private let event = MyTBAFavorite(modelKey: "2026miket", modelType: .event)
    private let team = MyTBAFavorite(modelKey: "frc7332", modelType: .team)

    // Installed apps already have their cache at these paths.
    @Test func defaultFilesKeepTheirNames() {
        #expect(FavoritesStore.defaultFileURL.lastPathComponent == "favorites.json")
        #expect(SubscriptionsStore.defaultFileURL.lastPathComponent == "subscriptions.json")
    }

    // MARK: - Favorites

    @Test func favoritesKeepOneEntryPerModelFromTheServer() {
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FavoritesStore(fileURL: favoritesURL)

        store.replaceAll(with: [event, team, event])

        #expect(store.favorites.count == 2)
        #expect(store.contains(eventID))
        #expect(store.contains(teamID))
    }

    @Test func favoritesKeepOneEntryPerModelFromDisk() async {
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = JSONFileStore<[MyTBAFavorite]>(url: favoritesURL)
        file.save([team, team])
        await file.flush()

        let store = FavoritesStore(fileURL: favoritesURL)

        #expect(store.favorites == [team])
    }

    @Test func favoritesRoundTripThroughDisk() async {
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FavoritesStore(fileURL: favoritesURL)
        store.replaceAll(with: [event, team])
        await store.flush()

        let reloaded = FavoritesStore(fileURL: favoritesURL)

        #expect(reloaded.favorites.count == 2)
        #expect(reloaded.contains(eventID))
        #expect(reloaded.contains(teamID))
    }

    @Test func removeDropsOnlyThatFavorite() {
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FavoritesStore(fileURL: favoritesURL)
        store.replaceAll(with: [event, team])

        store.remove(eventID)

        #expect(!store.contains(eventID))
        #expect(store.contains(teamID))
    }

    @Test func favoriteTeamKeysAreSorted() {
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FavoritesStore(fileURL: favoritesURL)

        store.replaceAll(with: [
            team,
            event,
            MyTBAFavorite(modelKey: "frc2337", modelType: .team),
        ])

        #expect(store.favoriteTeamKeys() == ["frc2337", "frc7332"])
    }

    // MARK: - Subscriptions

    @Test func subscriptionsKeepTheFirstOfEachModelFromTheServer() {
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = SubscriptionsStore(fileURL: subscriptionsURL)

        store.replaceAll(with: [
            MyTBASubscription(modelKey: "frc7332", modelType: .team, notifications: [.matchScore]),
            MyTBASubscription(modelKey: "2026miket", modelType: .event, notifications: [.awards]),
            MyTBASubscription(
                modelKey: "frc7332",
                modelType: .team,
                notifications: [.upcomingMatch]
            ),
        ])

        #expect(store.subscriptions.count == 2)
        #expect(store.subscription(for: teamID)?.notifications == [.matchScore])
        #expect(store.subscription(for: eventID)?.notifications == [.awards])
    }

    @Test func subscriptionsKeepTheFirstOfEachModelFromDisk() async {
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = JSONFileStore<[MyTBASubscription]>(url: subscriptionsURL)
        file.save([
            MyTBASubscription(modelKey: "2026miket", modelType: .event, notifications: [.awards]),
            MyTBASubscription(modelKey: "2026miket", modelType: .event, notifications: []),
        ])
        await file.flush()

        let store = SubscriptionsStore(fileURL: subscriptionsURL)

        #expect(store.subscriptions.count == 1)
        #expect(store.subscription(for: eventID)?.notifications == [.awards])
    }

    @Test func upsertReplacesTheExistingSubscription() {
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = SubscriptionsStore(fileURL: subscriptionsURL)
        store.upsert(
            MyTBASubscription(modelKey: "frc7332", modelType: .team, notifications: [.matchScore])
        )

        store.upsert(
            MyTBASubscription(modelKey: "frc7332", modelType: .team, notifications: [.awards])
        )

        #expect(store.subscriptions.count == 1)
        #expect(store.subscription(for: teamID)?.notifications == [.awards])
    }

    // MARK: - Subscribable models

    @Test func favoritesAreFoundBySubscribableModel() {
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FavoritesStore(fileURL: favoritesURL)
        store.replaceAll(with: [team])

        #expect(store.contains(Subscribable(modelKey: "frc7332", modelType: .team)))
        #expect(!store.contains(Subscribable(modelKey: "frc2337", modelType: .team)))
    }

    @Test func favoritesAreRemovedBySubscribableModel() {
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FavoritesStore(fileURL: favoritesURL)
        store.replaceAll(with: [event, team])

        store.remove(Subscribable(modelKey: "frc7332", modelType: .team))

        #expect(!store.contains(teamID))
        #expect(store.contains(eventID))
    }

    @Test func subscriptionsAreFoundAndRemovedBySubscribableModel() {
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = SubscriptionsStore(fileURL: subscriptionsURL)
        let model = Subscribable(modelKey: "2026miket", modelType: .event)
        store.upsert(
            MyTBASubscription(modelKey: "2026miket", modelType: .event, notifications: [.awards])
        )

        #expect(store.subscription(for: model)?.notifications == [.awards])

        store.remove(model)

        #expect(store.subscription(for: model) == nil)
    }
}

private struct Subscribable: MyTBASubscribable {
    let modelKey: String
    let modelType: MyTBAModelType
    static var notificationTypes: [NotificationType] { [] }
}
