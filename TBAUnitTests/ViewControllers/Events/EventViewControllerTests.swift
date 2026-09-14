import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct EventViewControllerTests {

    private static func status(downEventKeys: [String]) -> AppStatus {
        AppStatus(
            currentSeason: 2026,
            maxSeason: 2026,
            minAppVersion: -1,
            latestAppVersion: -1,
            isDatafeedDown: false,
            downEventKeys: downEventKeys,
            kickoffDate: nil
        )
    }

    @Test func offlineBannerFollowsTheStatusService() {
        let dependencies = Dependencies.mock()
        let statusService = dependencies.statusService as! MockStatusService
        let controller = EventViewController(eventKey: "2026casj", dependencies: dependencies)
        controller.loadViewIfNeeded()
        controller.updatePropertiesIfNeeded()
        let onlineCount = controller.rootStackView.arrangedSubviews.count

        statusService.status = Self.status(downEventKeys: ["2026casj"])
        controller.updatePropertiesIfNeeded()
        #expect(controller.rootStackView.arrangedSubviews.count == onlineCount + 1)

        statusService.status = Self.status(downEventKeys: [])
        controller.updatePropertiesIfNeeded()
        #expect(controller.rootStackView.arrangedSubviews.count == onlineCount)
    }

}
