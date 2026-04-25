import Testing

@testable import TBAAPI

struct APITeamHelpersTests {

    // MARK: - TeamKeys.trimFRCPrefix

    @Test func trimFRCPrefix_strip() {
        #expect(TeamKeys.trimFRCPrefix("frc2337") == "2337")
    }

    @Test func trimFRCPrefix_stripKeepsSuffix() {
        #expect(TeamKeys.trimFRCPrefix("frc2337b") == "2337b")
    }

    // MARK: - TeamKeys.parentKey

    @Test func parentKey_canonicalKeyUnchanged() {
        #expect(TeamKeys.parentKey("frc254") == "frc254")
    }

    @Test func parentKey_dropsBSuffix() {
        #expect(TeamKeys.parentKey("frc5940B") == "frc5940")
    }

    @Test func parentKey_dropsLowercaseSuffix() {
        #expect(TeamKeys.parentKey("frc5940b") == "frc5940")
    }

    // MARK: - TeamDisplayable (Team)

    @Test func teamNumberNickname_prependsTeam() {
        let team = makeTeam(teamNumber: 254)
        #expect(team.teamNumberNickname == "Team 254")
    }

    @Test func displayNickname_usesNicknameWhenSet() {
        let team = makeTeam(teamNumber: 254, nickname: "The Cheesy Poofs")
        #expect(team.displayNickname == "The Cheesy Poofs")
    }

    @Test func displayNickname_fallsBackToTeamNumber() {
        let team = makeTeam(teamNumber: 254, nickname: "")
        #expect(team.displayNickname == "Team 254")
    }

    // MARK: - Team.locationString

    @Test func team_locationString_nilWhenAllEmpty() {
        let team = makeTeam(teamNumber: 254)
        #expect(team.locationString == nil)
    }

    @Test func team_locationString_joinsParts() {
        let team = makeTeam(
            teamNumber: 254,
            city: "San Jose",
            stateProv: "CA",
            country: "USA"
        )
        #expect(team.locationString == "San Jose, CA, USA")
    }

    @Test func team_locationString_fallsBackToLocationName() {
        let team = makeTeam(teamNumber: 254, locationName: "Bellarmine College Prep")
        #expect(team.locationString == "Bellarmine College Prep")
    }

    // MARK: - Team.hasWebsite

    @Test func team_hasWebsite_nilIsFalse() {
        #expect(!makeTeam(teamNumber: 254).hasWebsite)
    }

    @Test func team_hasWebsite_emptyIsFalse() {
        #expect(!makeTeam(teamNumber: 254, website: "").hasWebsite)
    }

    @Test func team_hasWebsite_populatedIsTrue() {
        #expect(makeTeam(teamNumber: 254, website: "https://team254.com").hasWebsite)
    }

    // MARK: - TeamDisplayable (TeamSimple)

    @Test func teamSimple_displayNickname_fallsBackToTeamNumber() {
        let simple = makeTeamSimple(teamNumber: 254, nickname: "")
        #expect(simple.displayNickname == "Team 254")
    }

    @Test func teamSimple_locationString_nilWhenAllEmpty() {
        // TeamSimple has no locationName fallback — all-empty returns nil.
        let simple = makeTeamSimple(teamNumber: 254)
        #expect(simple.locationString == nil)
    }

    // MARK: - Test helpers

    private func makeTeam(
        teamNumber: Int,
        nickname: String = "",
        city: String? = nil,
        stateProv: String? = nil,
        country: String? = nil,
        locationName: String? = nil,
        website: String? = nil
    ) -> Team {
        Team(
            key: "frc\(teamNumber)",
            teamNumber: teamNumber,
            nickname: nickname,
            name: "",
            city: city,
            stateProv: stateProv,
            country: country,
            locationName: locationName,
            website: website
        )
    }

    private func makeTeamSimple(
        teamNumber: Int,
        nickname: String = "",
        city: String? = nil,
        stateProv: String? = nil,
        country: String? = nil
    ) -> TeamSimple {
        TeamSimple(
            key: "frc\(teamNumber)",
            teamNumber: teamNumber,
            nickname: nickname,
            name: "",
            city: city,
            stateProv: stateProv,
            country: country
        )
    }
}
