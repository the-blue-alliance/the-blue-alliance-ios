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
        let service = StatusService(reporter: MockReporter(), api: api)
        service.start()
        #expect(await Self.waitForRequests(api, count: 1) == 1)

        NotificationCenter.default.post(
            name: UIApplication.willEnterForegroundNotification,
            object: UIApplication.shared
        )

        #expect(await Self.waitForRequests(api, count: 2) == 2)
    }

}
