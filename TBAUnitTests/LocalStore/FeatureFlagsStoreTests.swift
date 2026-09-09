import Foundation
import Testing

@testable import The_Blue_Alliance

struct FeatureFlagsStoreTests {

    @Test(arguments: FeatureFlag.allCases)
    func everyFlagDefaultsOff(flag: FeatureFlag) {
        let store = FeatureFlagsStore(defaults: UserDefaults(suiteName: UUID().uuidString)!)
        #expect(store.isEnabled(flag) == false)
    }

    @Test func flagRoundTripsThroughDefaultsUnderItsKey() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let store = FeatureFlagsStore(defaults: defaults)

        store.setEnabled(true, for: .dashboard)
        #expect(store.isEnabled(.dashboard) == true)
        #expect(FeatureFlagsStore(defaults: defaults).isEnabled(.dashboard) == true)
        #expect(defaults.bool(forKey: "kTBAFeatureFlag.dashboard") == true)

        store.setEnabled(false, for: .dashboard)
        #expect(FeatureFlagsStore(defaults: defaults).isEnabled(.dashboard) == false)
    }

    @Test func pruneDropsRetiredFlagsAndLeavesEverythingElse() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let store = FeatureFlagsStore(defaults: defaults)
        store.setEnabled(true, for: .dashboard)
        defaults.set(true, forKey: "kTBAFeatureFlag.retiredFeature")
        defaults.set("bypass", forKey: "kTBACachePolicy")

        store.pruneRetiredFlags()

        #expect(store.isEnabled(.dashboard) == true)
        #expect(defaults.object(forKey: "kTBAFeatureFlag.retiredFeature") == nil)
        #expect(defaults.string(forKey: "kTBACachePolicy") == "bypass")
    }

    @Test func dashboardNeedsARelaunch() {
        #expect(FeatureFlag.dashboard.requiresRelaunch)
        #expect(FeatureFlag.dashboard.title == "Dashboard")
    }

}
