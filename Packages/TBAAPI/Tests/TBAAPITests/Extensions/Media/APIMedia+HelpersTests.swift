import Foundation
import Testing

@testable import TBAAPI

// `Media` is a discriminated union in the spec, so these decode the wire shape the
// API emits rather than constructing payloads by hand.
struct APIMediaHelpersTests {

    @Test func avatar_flattensBaseAndExposesImage() throws {
        let media = try decode(
            """
            {
              "type": "avatar",
              "foreign_key": "avatar_2026_frc254",
              "team_keys": ["frc254"],
              "preferred": false,
              "direct_url": "",
              "view_url": "",
              "details": { "base64Image": "aGVsbG8=" }
            }
            """
        )
        #expect(media.type == .avatar)
        #expect(media.foreignKey == "avatar_2026_frc254")
        #expect(media.teamKeys == ["frc254"])
        #expect(media.avatarBase64Image == "aGVsbG8=")
    }

    @Test func imgur_hasNoAvatarImage() throws {
        let media = try decode(
            """
            {
              "type": "imgur",
              "foreign_key": "abc123",
              "team_keys": ["frc254"],
              "preferred": true,
              "direct_url": "https://i.imgur.com/abc123.jpg",
              "view_url": "https://imgur.com/abc123",
              "details": {}
            }
            """
        )
        #expect(media.type == .imgur)
        #expect(media.preferred == true)
        #expect(media.directUrl == "https://i.imgur.com/abc123.jpg")
        #expect(media.viewUrl == "https://imgur.com/abc123")
        #expect(media.avatarBase64Image == nil)
    }

    @Test func youtube_decodesAsNoDetails() throws {
        let media = try decode(
            """
            {
              "type": "youtube",
              "foreign_key": "dQw4w9WgXcQ",
              "team_keys": ["frc254"],
              "details": {}
            }
            """
        )
        #expect(media.type == .youtube)
        #expect(media.foreignKey == "dQw4w9WgXcQ")
        #expect(media.directUrl == nil)
    }

    private func decode(_ json: String) throws -> Media {
        try JSONDecoder().decode(Media.self, from: Data(json.utf8))
    }

}
