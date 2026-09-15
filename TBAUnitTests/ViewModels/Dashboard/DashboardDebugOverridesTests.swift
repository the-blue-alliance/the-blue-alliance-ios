import Foundation
import MyTBAKit
import Testing

@testable import The_Blue_Alliance

@MainActor
struct DashboardDebugOverridesTests {

    private static func favorites() -> FavoritesStore {
        let store = FavoritesStore(
            fileURL: URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("\(UUID().uuidString).json")
        )
        store.replaceAll(with: [
            MyTBAFavorite(modelKey: "frc254", modelType: .team),
            MyTBAFavorite(modelKey: "2026casj", modelType: .event),
            MyTBAFavorite(modelKey: "2026casj_qm1", modelType: .match),
        ])
        return store
    }

    @Test func withoutOverrides_followsComeFromFavorites() {
        let overrides = DashboardDebugOverrides()
        let follows = overrides.effectiveFollows(favorites: Self.favorites())
        #expect(follows.teamKeys == ["frc254"])
        #expect(follows.eventKeys == ["2026casj"])
        #expect(overrides.isActive == false)
    }

    @Test func overridesReplaceFavoritesIndependently() {
        let overrides = DashboardDebugOverrides()
        overrides.teamKeys = ["frc1678"]
        let follows = overrides.effectiveFollows(favorites: Self.favorites())
        #expect(follows.teamKeys == ["frc1678"])
        #expect(follows.eventKeys == ["2026casj"])
        #expect(overrides.isActive)

        overrides.reset()
        #expect(overrides.isActive == false)
    }

    @Test func teamTextParsesNumbersAndKeys() {
        #expect(DashboardDebugOverrides.teamKeys(from: "254, 1678 frc118") == ["frc254", "frc1678", "frc118"])
        #expect(DashboardDebugOverrides.teamKeys(from: "  ") == nil)
        #expect(DashboardDebugOverrides.eventKeys(from: "2026CASJ,2026cc") == ["2026casj", "2026cc"])
        #expect(DashboardDebugOverrides.eventKeys(from: "") == nil)
    }

}
