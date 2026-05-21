import Testing

@testable import TBAAPI

struct APITeamHelpersTests {

    // MARK: - TeamKey.trimPrefix

    @Test func trimPrefix_strip() {
        #expect(("frc2337" as TeamKey).trimPrefix == "2337")
    }

    @Test func trimPrefix_stripKeepsSuffix() {
        #expect(("frc2337b" as TeamKey).trimPrefix == "2337b")
    }

    // MARK: - TeamKey.teamNumber

    @Test func teamNumber_parsesDigits() {
        #expect(("frc254" as TeamKey).teamNumber == 254)
    }

    @Test func teamNumber_nilForBTeamSuffix() {
        #expect(("frc5940B" as TeamKey).teamNumber == nil)
    }

    // MARK: - TeamKey.parentKey

    @Test func parentKey_canonicalKeyUnchanged() {
        #expect(("frc254" as TeamKey).parentKey == "frc254")
    }

    @Test func parentKey_dropsBSuffix() {
        #expect(("frc5940B" as TeamKey).parentKey == "frc5940")
    }

    @Test func parentKey_dropsLowercaseSuffix() {
        #expect(("frc5940b" as TeamKey).parentKey == "frc5940")
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

    // MARK: - TeamDisplayable.nonFallbackNickname

    @Test func nonFallbackNickname_nilWhenEmpty() {
        let team = makeTeam(teamNumber: 18, nickname: "")
        #expect(team.nonFallbackNickname == nil)
    }

    @Test func nonFallbackNickname_nilForFallback() {
        let team = makeTeam(teamNumber: 18, nickname: "Team 18")
        #expect(team.nonFallbackNickname == nil)
    }

    @Test func nonFallbackNickname_returnsRealNickname() {
        let team = makeTeam(teamNumber: 254, nickname: "The Cheesy Poofs")
        #expect(team.nonFallbackNickname == "The Cheesy Poofs")
    }

    @Test func teamSimple_nonFallbackNickname_nilForFallback() {
        let simple = makeTeamSimple(teamNumber: 18, nickname: "Team 18")
        #expect(simple.nonFallbackNickname == nil)
    }

    @Test func teamSimple_nonFallbackNickname_returnsRealNickname() {
        let simple = makeTeamSimple(teamNumber: 254, nickname: "The Cheesy Poofs")
        #expect(simple.nonFallbackNickname == "The Cheesy Poofs")
    }

    // MARK: - TeamDisplayable.nonFallback(_:forTeamNumber:)

    @Test func nonFallbackStatic_nilForNil() {
        #expect(Team.nonFallback(nil, forTeamNumber: 18) == nil)
    }

    @Test func nonFallbackStatic_nilForEmpty() {
        #expect(Team.nonFallback("", forTeamNumber: 18) == nil)
    }

    @Test func nonFallbackStatic_nilForFallback() {
        #expect(Team.nonFallback("Team 18", forTeamNumber: 18) == nil)
    }

    @Test func nonFallbackStatic_returnsRealNickname() {
        #expect(Team.nonFallback("The Cheesy Poofs", forTeamNumber: 254) == "The Cheesy Poofs")
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
