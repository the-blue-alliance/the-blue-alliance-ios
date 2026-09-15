import Foundation
import TBAAPI
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

    @Test func eventScreensArePushedWithTheirTitleAndTheEvent() {
        let event = Event(
            key: "2026casj",
            name: "Silicon Valley Regional",
            eventCode: "casj",
            eventType: ._0,
            startDate: "2026-03-26",
            endDate: "2026-03-29",
            year: 2026,
            eventTypeString: "Regional",
            week: 4,
            webcasts: [],
            divisionKeys: [],
            parentEventKey: nil
        )
        let screens: [(show: (EventViewController) -> Void, title: String)] = [
            ({ $0.showAlliances() }, "Alliances"),
            ({ $0.showAwards() }, "Awards"),
            ({ $0.showDistrictPoints() }, "District Points"),
        ]
        for screen in screens {
            let controller = EventViewController(event: event, dependencies: Dependencies.mock())
            let navigationController = UINavigationController(rootViewController: controller)
            screen.show(controller)

            let pushed = navigationController.topViewController
            #expect(pushed !== controller)
            #expect(pushed?.navigationItem.title == screen.title)
            #expect(pushed?.navigationItem.subtitle == "@ \(event.friendlyNameWithYear)")
        }
    }

}
