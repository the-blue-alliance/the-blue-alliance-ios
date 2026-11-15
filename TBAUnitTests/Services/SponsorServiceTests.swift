import Foundation
import TBAAPI
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct SponsorServiceTests {

    private static let andyMark = Sponsor(
        name: "AndyMark",
        url: "https://www.andymark.com/",
        logoStyle: "wordmark",
        logoUrl: "https://example.com/andymark-on-light.png",
        logoUrlDark: "https://example.com/andymark-on-dark.png"
    )

    private final class Clock {
        var now = Date(timeIntervalSince1970: 1_800_000_000)
        func advance(by interval: TimeInterval) { now += interval }
    }

    private static func makeService(
        api: MockTBAAPI,
        fileURL: URL = temporaryFileURL(),
        clock: Clock = Clock()
    ) -> SponsorService {
        SponsorService(api: api, fileURL: fileURL, now: { clock.now }, loadData: { _ in Data() })
    }

    private static func temporaryFileURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("sponsors.json")
    }

    // MARK: - Mapping

    @Test func mapsAllFields() throws {
        let sponsor = try #require(PlatinumSponsor(apiSponsor: Self.andyMark))
        #expect(sponsor.name == "AndyMark")
        #expect(sponsor.url == URL(string: "https://www.andymark.com/"))
        #expect(sponsor.logoStyle == .wordmark)
        #expect(sponsor.logoURL == URL(string: "https://example.com/andymark-on-light.png"))
        #expect(sponsor.logoURLDark == URL(string: "https://example.com/andymark-on-dark.png"))
    }

    @Test func unknownLogoStyleIsAWordmark() {
        #expect(PlatinumSponsor.LogoStyle(apiValue: "mark") == .mark)
        #expect(PlatinumSponsor.LogoStyle(apiValue: "wordmark") == .wordmark)
        #expect(PlatinumSponsor.LogoStyle(apiValue: "banner") == .wordmark)
    }

    @Test func nullLogosMapToNil() throws {
        let sponsor = try #require(
            PlatinumSponsor(
                apiSponsor: Sponsor(
                    name: "Quillfeather Robotics",
                    url: "https://example.com/",
                    logoStyle: "mark",
                    logoUrl: nil,
                    logoUrlDark: nil
                )
            )
        )
        #expect(sponsor.logoURL == nil)
        #expect(sponsor.logoURLDark == nil)
        #expect(sponsor.logoURL(for: .light) == nil)
        #expect(sponsor.logoURL(for: .dark) == nil)
    }

    // MARK: - Presentation

    @Test func creditTitlePluralizes() {
        #expect(PlatinumSponsor.creditTitle(count: 1) == "Thanks to our platinum sponsor")
        #expect(PlatinumSponsor.creditTitle(count: 2) == "Thanks to our platinum sponsors")
        #expect(PlatinumSponsor.creditTitle(count: 3) == "Thanks to our platinum sponsors")
    }

    @Test func logoVariantFollowsTheInterfaceStyle() throws {
        let light = URL(string: "https://example.com/light.png")!
        let dark = URL(string: "https://example.com/dark.png")!
        func sponsor(light: URL?, dark: URL?) -> PlatinumSponsor {
            PlatinumSponsor(
                name: "AndyMark",
                url: URL(string: "https://www.andymark.com/")!,
                logoStyle: .wordmark,
                logoURL: light,
                logoURLDark: dark
            )
        }
        let both = sponsor(light: light, dark: dark)
        #expect(both.logoURL(for: .light) == light)
        #expect(both.logoURL(for: .dark) == dark)
        #expect(both.logoURL(for: .unspecified) == light)
        // Each mode falls back to the other variant.
        #expect(sponsor(light: nil, dark: dark).logoURL(for: .light) == dark)
        #expect(sponsor(light: light, dark: nil).logoURL(for: .dark) == light)
    }

    // MARK: - Caching

    @Test func fetchesOnceADay() async {
        let api = MockTBAAPI()
        api.sponsors = [Self.andyMark]
        let clock = Clock()
        let service = Self.makeService(api: api, clock: clock)

        #expect(await service.refresh().map(\.name) == ["AndyMark"])
        clock.advance(by: SponsorService.maxAge - 1)
        api.sponsors = []
        #expect(await service.refresh().map(\.name) == ["AndyMark"])
        #expect(api.sponsorsRequestCount == 1)

        clock.advance(by: 1)
        #expect(await service.refresh().isEmpty)
        #expect(api.sponsorsRequestCount == 2)
    }

    @Test func emptyListIsCachedToo() async {
        let api = MockTBAAPI()
        api.sponsors = []
        let service = Self.makeService(api: api)

        #expect(await service.refresh().isEmpty)
        #expect(await service.refresh().isEmpty)
        #expect(api.sponsorsRequestCount == 1)
    }

    @Test func failedFetchWithNothingCachedShowsNothing() async {
        let api = MockTBAAPI()
        let service = Self.makeService(api: api)

        #expect(await service.refresh().isEmpty)
        #expect(service.sponsors.isEmpty)
    }

    @Test func failedFetchKeepsTheLastList() async {
        let api = MockTBAAPI()
        api.sponsors = [Self.andyMark]
        let clock = Clock()
        let service = Self.makeService(api: api, clock: clock)
        _ = await service.refresh()

        api.sponsors = nil
        clock.advance(by: SponsorService.maxAge)
        #expect(await service.refresh().map(\.name) == ["AndyMark"])
        #expect(api.sponsorsRequestCount == 2)
        // A failure doesn't count as a fetch, so the next visit tries again.
        #expect(await service.refresh().map(\.name) == ["AndyMark"])
        #expect(api.sponsorsRequestCount == 3)
    }

    @Test func lastListSurvivesARelaunch() async {
        let api = MockTBAAPI()
        api.sponsors = [Self.andyMark]
        let fileURL = Self.temporaryFileURL()
        let clock = Clock()
        let first = Self.makeService(api: api, fileURL: fileURL, clock: clock)
        _ = await first.refresh()
        await first.flush()

        let relaunched = Self.makeService(api: api, fileURL: fileURL, clock: clock)
        #expect(relaunched.sponsors.map(\.name) == ["AndyMark"])
        #expect(await relaunched.refresh().map(\.name) == ["AndyMark"])
        #expect(api.sponsorsRequestCount == 1)
    }

    @Test func logosAreDecodedOnce() async throws {
        var loads = 0
        let png = try #require(
            UIGraphicsImageRenderer(size: CGSize(width: 4, height: 2)).image { _ in }.pngData()
        )
        let service = SponsorService(
            api: MockTBAAPI(),
            fileURL: Self.temporaryFileURL(),
            loadData: { _ in
                loads += 1
                return png
            }
        )
        let url = URL(string: "https://example.com/logo.png")!

        #expect(await service.image(for: url) != nil)
        #expect(await service.image(for: url) != nil)
        #expect(loads == 1)
    }

    @Test func unreadableLogoIsNil() async {
        let service = SponsorService(
            api: MockTBAAPI(),
            fileURL: Self.temporaryFileURL(),
            loadData: { _ in throw URLError(.badServerResponse) }
        )
        #expect(await service.image(for: URL(string: "https://example.com/logo.png")!) == nil)
    }

}
