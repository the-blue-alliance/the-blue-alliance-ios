import Testing

@testable import TBAAPI

struct APIWebcastHelpersTests {

    // MARK: - typeString

    @Test func typeString_forwardsRawValue() {
        #expect(makeWebcast(type: .twitch, channel: "firstinmichigan").typeString == "twitch")
    }

    // MARK: - displayName

    @Test func displayName_youtube() {
        #expect(makeWebcast(type: .youtube, channel: "abc").displayName == "YouTube")
    }

    @Test func displayName_twitch() {
        #expect(makeWebcast(type: .twitch, channel: "firstinmichigan").displayName == "Twitch")
    }

    @Test func displayName_directLink_domainOnly() {
        // URL host is "espn.com" → last two parts joined → "espn.com".
        let webcast = makeWebcast(type: .directLink, channel: "https://www.espn.com/live")
        #expect(webcast.displayName == "espn.com")
    }

    @Test func displayName_directLink_invalidURLFallsBack() {
        let webcast = makeWebcast(type: .directLink, channel: "")
        #expect(webcast.displayName == "website")
    }

    @Test func displayName_unrecognizedForwardsRawValue() {
        let webcast = makeWebcast(type: .iframe, channel: "<iframe>")
        #expect(webcast.displayName == "iframe")
    }

    // MARK: - urlString

    @Test func urlString_twitch() {
        let webcast = makeWebcast(type: .twitch, channel: "firstinmichigan")
        #expect(webcast.urlString == "https://twitch.tv/firstinmichigan")
    }

    @Test func urlString_youtube() {
        let webcast = makeWebcast(type: .youtube, channel: "dQw4w9WgXcQ")
        #expect(webcast.urlString == "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    }

    @Test func urlString_directLink_forwardsChannel() {
        let webcast = makeWebcast(type: .directLink, channel: "https://example.com/live")
        #expect(webcast.urlString == "https://example.com/live")
    }

    @Test func urlString_unrecognizedIsNil() {
        let webcast = makeWebcast(type: .iframe, channel: "<iframe>")
        #expect(webcast.urlString == nil)
    }

    // MARK: - dateParsed

    @Test func dateParsed_nilWhenNoDate() {
        let webcast = makeWebcast(type: .twitch, channel: "x", date: nil)
        #expect(webcast.dateParsed == nil)
    }

    @Test func dateParsed_parsesYYYYMMDD() {
        let webcast = makeWebcast(type: .twitch, channel: "x", date: "2024-03-05")
        #expect(webcast.dateParsed != nil)
    }

    @Test func dateParsed_nilForGarbage() {
        let webcast = makeWebcast(type: .twitch, channel: "x", date: "not a date")
        #expect(webcast.dateParsed == nil)
    }

    // MARK: - Test helpers

    private func makeWebcast(
        type: Webcast._TypePayload,
        channel: String,
        date: String? = nil
    ) -> Webcast {
        Webcast(_type: type, channel: channel, date: date)
    }
}
