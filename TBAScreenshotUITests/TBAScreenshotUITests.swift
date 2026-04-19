import XCTest

final class TBAScreenshotUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testScreenshots() {
        let app = XCUIApplication(bundleIdentifier: "com.the-blue-alliance.tba")
        setupSnapshot(app)
        app.launch()

        // 01 — Events list (events_2026 fixture, week 0 filter shows Mt Pleasant)
        snapshot("01_events")

        // Navigate into the canonical 2026 Mt Pleasant event.
        waitForTap(app.cells["event.2026mimtp"])

        // 02 — Event info tab (first segment — opens on Info by default)
        snapshot("02_team")

        // 03 — Matches tab within the event
        waitForTap(app.segmentedControls.buttons["Matches"])
        snapshot("03_matches")

        // 04 — Rankings tab within the event
        waitForTap(app.segmentedControls.buttons["Rankings"])
        snapshot("04_rankings")

        // 05 — Team@Event — switch to Teams tab, tap the first team cell, showing Summary.
        waitForTap(app.segmentedControls.buttons["Teams"])
        // First team in the list (sorted by team_number ascending).
        waitForTap(app.cells.firstMatch)
        snapshot("05_team_at_event")

        // Back to the event detail; navigate the Matches tab.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        waitForTap(app.segmentedControls.buttons["Matches"])

        // 06 — Match detail (info tab — opens first)
        waitForTap(app.cells.firstMatch)
        snapshot("06_match")

        // 07 — Match breakdown tab
        waitForTap(app.segmentedControls.buttons["Breakdown"])
        snapshot("07_breakdown")

        // 08 — myTBA tab. UITab's `identifier` parameter doesn't project onto
        // the accessibility tree, so we address tabs by their title instead.
        waitForTap(tabBarButton(app, title: "myTBA"))
        snapshot("08_mytba")

        // 09 — Team Media — open Teams tab, pick Team 1711 (RAPTORS) which has
        // real imgur robot photos for 2026 so the media grid renders actual
        // images instead of the empty avatar-only grid team 573 produces.
        waitForTap(tabBarButton(app, title: "Teams"))
        waitForTap(app.cells["team.frc1711"])
        waitForTap(app.segmentedControls.buttons["Media"])
        // Wait for media download. Imgur isn't behind the fixture layer, so
        // these are live network fetches during the test — give them a couple
        // of seconds before snapping.
        Thread.sleep(forTimeInterval: 3.0)
        snapshot("09_team_media")

        // 10 — District rankings — open Districts, tap FIM, switch to Rankings.
        waitForTap(tabBarButton(app, title: "Districts"))
        waitForTap(app.cells["district.2026fim"])
        waitForTap(app.segmentedControls.buttons["Rankings"])
        snapshot("10_district_rankings")
    }

    private func waitForTap(_ element: XCUIElement, timeout: TimeInterval = 10) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout),
                      "Element did not appear in time: \(element)")
        element.tap()
    }

    // UITab sets `identifier` for state restoration only — it doesn't project
    // onto the accessibility tree. Match each tab by its on-screen title from
    // the top-level button collection so XCUITest finds it wherever iOS 26's
    // sidebar-capable tab bar places it.
    private func tabBarButton(_ app: XCUIApplication, title: String) -> XCUIElement {
        app.buttons[title].firstMatch
    }

}
