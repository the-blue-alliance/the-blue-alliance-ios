import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

// The Experimental section only exists in debug simulator builds, which is where these run.
@MainActor
struct SettingsViewControllerTests {

    private final class Harness {
        let window: UIWindow
        let settings: SettingsViewController
        let dependencies: Dependencies

        init(dashboardEnabled: Bool) {
            dependencies = Dependencies.mock()
            dependencies.appSettings.featureFlags.setEnabled(dashboardEnabled, for: .dashboard)
            settings = SettingsViewController(
                fcmTokenProvider: MockFCMTokenProvider(),
                pushService: MockPushService(),
                dependencies: dependencies
            )
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
            window.rootViewController = settings
            window.makeKeyAndVisible()
            settings.loadViewIfNeeded()
        }

        var experimentalToggle: UISwitch? {
            let tableView = settings.tableView!
            let section = (0..<tableView.numberOfSections).first {
                settings.tableView(tableView, titleForHeaderInSection: $0) == "Experimental"
            }
            guard let section else { return nil }
            let cell = settings.tableView(
                tableView,
                cellForRowAt: IndexPath(row: 0, section: section)
            )
            return cell.accessoryView as? UISwitch
        }
    }

    @Test func experimentalSectionReflectsTheFlag() {
        #expect(Harness(dashboardEnabled: false).experimentalToggle?.isOn == false)
        #expect(Harness(dashboardEnabled: true).experimentalToggle?.isOn == true)
    }

    @Test func togglingWritesTheFlagAndAsksForARelaunch() throws {
        let harness = Harness(dashboardEnabled: false)
        let toggle = try #require(harness.experimentalToggle)

        toggle.isOn = true
        toggle.sendActions(for: .valueChanged)
        #expect(harness.dependencies.appSettings.featureFlags.isEnabled(.dashboard) == true)

        let alert = harness.settings.presentedViewController as? UIAlertController
        #expect(alert?.title == "Relaunch to Apply")
    }

}
