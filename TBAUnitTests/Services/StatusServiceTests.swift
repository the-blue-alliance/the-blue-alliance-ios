import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct StatusServiceTests {

    private static func waitForRequests(_ api: MockTBAAPI, count: Int) async -> Int {
        for _ in 0..<200 where api.statusRequestCount != count {
            try? await Task.sleep(for: .milliseconds(10))
        }
        return api.statusRequestCount
    }

    @Test func comingBackToTheForegroundChecksStatusRightAway() async {
        let api = MockTBAAPI()
        // Its own center, so other tests coming back to the foreground in parallel don't
        // restart this service's polling and count extra requests.
        let notificationCenter = NotificationCenter()
        let service = StatusService(
            reporter: MockReporter(),
            api: api,
            notificationCenter: notificationCenter
        )
        service.start()
        #expect(await Self.waitForRequests(api, count: 1) == 1)

        notificationCenter.post(
            name: UIApplication.willEnterForegroundNotification,
            object: UIApplication.shared
        )

        #expect(await Self.waitForRequests(api, count: 2) == 2)
    }

}
