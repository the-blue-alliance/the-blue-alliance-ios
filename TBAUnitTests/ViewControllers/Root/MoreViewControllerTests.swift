import Foundation
import TBAAPI
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct MoreViewControllerTests {

    private final class Harness {
        let window: UIWindow
        let more: MoreViewController
        let dependencies: Dependencies

        init(api: MockTBAAPI = MockTBAAPI()) {
            dependencies = Dependencies.mock(api: api)
            more = MoreViewController(
                items: [.teams, .settings],
                sponsorService: dependencies.sponsorService,
                urlOpener: dependencies.urlOpener
            ) { _ in UIViewController() }
            window = UIWindow.makeForTesting()
            window.rootViewController = more
            window.makeKeyAndVisible()
            more.loadViewIfNeeded()
        }

        var sponsorCredit: SponsorCreditView? {
            more.tableView.tableFooterView as? SponsorCreditView
        }

        /// Waits for the fetch `viewWillAppear` starts.
        func appearAndWaitForSponsors(requests: Int = 1) async {
            more.beginAppearanceTransition(true, animated: false)
            more.endAppearanceTransition()
            let api = dependencies.api as? MockTBAAPI
            for _ in 0..<200 where sponsorCredit == nil && api?.sponsorsRequestCount != requests {
                try? await Task.sleep(for: .milliseconds(10))
            }
            await Task.yield()
        }
    }

    private static let andyMark = Sponsor(
        name: "AndyMark",
        url: "https://www.andymark.com/",
        logoStyle: "wordmark",
        logoUrl: nil,
        logoUrlDark: nil
    )

    @Test func noSponsorsMeansNoCredit() async {
        let api = MockTBAAPI()
        api.sponsors = []
        let harness = Harness(api: api)
        await harness.appearAndWaitForSponsors()
        #expect(api.sponsorsRequestCount == 1)
        #expect(harness.sponsorCredit == nil)
    }

    @Test func failedFetchMeansNoCredit() async {
        let api = MockTBAAPI()
        let harness = Harness(api: api)
        await harness.appearAndWaitForSponsors()
        #expect(api.sponsorsRequestCount == 1)
        #expect(harness.sponsorCredit == nil)
    }

    @Test func creditListsSponsorsBelowTheLastRow() async throws {
        let api = MockTBAAPI()
        api.sponsors = [
            Self.andyMark,
            Sponsor(
                name: "Quillfeather Robotics",
                url: "https://example.com/",
                logoStyle: "mark",
                logoUrl: nil,
                logoUrlDark: nil
            ),
        ]
        let harness = Harness(api: api)
        await harness.appearAndWaitForSponsors()

        let credit = try #require(harness.sponsorCredit)
        #expect(credit.titleLabel.text == "Thanks to our platinum sponsors")
        #expect(
            credit.itemViews.map(\.accessibilityLabel) == ["AndyMark", "Quillfeather Robotics"]
        )
        #expect(credit.frame.height > 0)
    }

    @Test func tappingASponsorOpensItsSite() async throws {
        let api = MockTBAAPI()
        api.sponsors = [Self.andyMark]
        let harness = Harness(api: api)
        await harness.appearAndWaitForSponsors()

        let credit = try #require(harness.sponsorCredit)
        #expect(credit.titleLabel.text == "Thanks to our platinum sponsor")
        credit.itemViews[0].sendActions(for: .touchUpInside)
        let opener = harness.dependencies.urlOpener as? MockURLOpener
        #expect(opener?.opened == [URL(string: "https://www.andymark.com/")!])
    }

    // MARK: - Bottom alignment

    @Test func creditFillsDownToTheBottomWhenTheRowsFit() {
        #expect(MoreViewController.creditHeight(fitting: 80, top: 200, visibleHeight: 700) == 500)
    }

    @Test func creditFollowsTheRowsWhenTheyDontFit() {
        #expect(MoreViewController.creditHeight(fitting: 80, top: 650, visibleHeight: 700) == 80)
        #expect(MoreViewController.creditHeight(fitting: 80, top: 900, visibleHeight: 700) == 80)
    }

    @Test func creditEndsAtTheBottomOfTheVisibleArea() async throws {
        let api = MockTBAAPI()
        api.sponsors = [Self.andyMark]
        let harness = Harness(api: api)
        await harness.appearAndWaitForSponsors()
        harness.more.view.layoutIfNeeded()

        let credit = try #require(harness.sponsorCredit)
        let tableView = harness.more.tableView
        let visibleBottom =
            tableView.bounds.height - tableView.adjustedContentInset.top
            - tableView.adjustedContentInset.bottom
        #expect(abs(credit.frame.maxY - visibleBottom) <= 1)
        // The content sits at the bottom of the taller footer.
        let fitting = credit.sizeThatFits(tableView.bounds.size).height
        #expect(credit.frame.height > fitting)
        #expect(credit.titleLabel.frame.minY >= credit.frame.height - fitting)
    }

    @Test func longSponsorNameWrapsInsteadOfOverflowing() throws {
        let sponsor = try #require(
            PlatinumSponsor(
                apiSponsor: Sponsor(
                    name: "Quillfeather Robotics and Fabrication",
                    url: "https://example.com/",
                    logoStyle: "mark",
                    logoUrl: nil,
                    logoUrlDark: nil
                )
            )
        )
        let item = SponsorItemView(sponsor: sponsor, loadImage: { _ in nil })
        let oneLine = item.sizeThatFits(CGSize(width: 10_000, height: 10_000))
        let wrapped = item.sizeThatFits(CGSize(width: 100, height: 10_000))
        #expect(wrapped.width <= 100)
        #expect(wrapped.height > oneLine.height)
    }

}
