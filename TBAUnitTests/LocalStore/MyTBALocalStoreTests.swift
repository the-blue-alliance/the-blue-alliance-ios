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
        #expect(store.subscription(teamID)?.notifications == [.matchScore])
        #expect(store.subscription(eventID)?.notifications == [.awards])
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
        #expect(store.subscription(eventID)?.notifications == [.awards])
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
        #expect(store.subscription(teamID)?.notifications == [.awards])
    }
}
