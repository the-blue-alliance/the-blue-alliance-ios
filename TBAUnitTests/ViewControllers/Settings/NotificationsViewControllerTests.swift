import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct NotificationsViewControllerTests {

    // Leaving the screen cancels the myTBA check, but its request still finishes, and coming
    // back shouldn't find the row still checking.
    @Test func leavingDuringTheMyTBACheckStillShowsItsResult() async throws {
        let dependencies = Dependencies.mock()
        let authService = try #require(dependencies.authService as? MockAuthService)
        authService.isSignedIn = true
        let pushService = MockPushService()
        pushService.holdsRegisterWithTBA = true
        let controller = NotificationsViewController(
            pushService: pushService,
            dependencies: dependencies
        )
        let window = UIWindow.makeForTesting()
        window.rootViewController = controller
        window.makeKeyAndVisible()
        let tableView = try #require(controller.tableView)
        func viewModel(ofRow row: Int) -> NotificationStatusCellViewModel? {
            tableView.layoutIfNeeded()
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
            return (cell as? NotificationStatusTableViewCell)?.viewModel
        }
        func title(ofRow row: Int) -> String? {
            viewModel(ofRow: row)?.title
        }
        func deviceCheckStarted() -> Bool {
            switch viewModel(ofRow: 1)?.notificationStatus {
            case .loading, .valid, .invalid: return true
            case .unknown, nil: return false
            }
        }
        func waitUntil(_ condition: () -> Bool) async {
            for _ in 0..<200 where !condition() {
                try? await Task.sleep(for: .milliseconds(10))
            }
        }
        // The device settings check reloads the table as it starts and as it finishes, either
        // of which could cover for a missing reload. Its start is waited out; how soon it
        // finishes depends on the simulator.
        await waitUntil(deviceCheckStarted)
        #expect(deviceCheckStarted())
        #expect(title(ofRow: 3) == "Checking myTBA Registration...")

        controller.viewWillDisappear(false)
        pushService.holdsRegisterWithTBA = false
        await waitUntil { title(ofRow: 3) == "myTBA Registration" }

        #expect(title(ofRow: 3) == "myTBA Registration")
    }

}
