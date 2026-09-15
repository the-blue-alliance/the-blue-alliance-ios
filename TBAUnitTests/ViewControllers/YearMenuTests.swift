import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct YearMenuTests {

    private static func status(maxSeason: Int) -> AppStatus {
        AppStatus(
            currentSeason: 2026,
            maxSeason: maxSeason,
            minAppVersion: -1,
            latestAppVersion: -1,
            isDatafeedDown: false,
            downEventKeys: [],
            kickoffDate: nil
        )
    }

    private static func latestYear(in container: ContainerViewController) -> String? {
        let button = container.rightBarButtonItems.first?.customView as? UIButton
        return button?.menu?.children.first?.title
    }

    private static func expectMenuFollowsMaxSeason(
        _ makeContainer: (Dependencies) -> ContainerViewController
    ) {
        let dependencies = Dependencies.mock()
        let statusService = dependencies.statusService as! MockStatusService
        statusService.status = status(maxSeason: 2026)
        let container = makeContainer(dependencies)
        container.loadViewIfNeeded()
        container.updatePropertiesIfNeeded()
        #expect(latestYear(in: container) == "2026")

        statusService.status = status(maxSeason: 2027)
        container.updatePropertiesIfNeeded()
        #expect(latestYear(in: container) == "2027")
    }

    @Test func eventsYearMenuFollowsTheMaxSeason() {
        Self.expectMenuFollowsMaxSeason { EventsContainerViewController(dependencies: $0) }
    }

    @Test func districtsYearMenuFollowsTheMaxSeason() {
        Self.expectMenuFollowsMaxSeason { DistrictsContainerViewController(dependencies: $0) }
    }

}
