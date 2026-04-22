import Testing

@testable import TBAAPI

struct APIMatchHelpersTests {

    // MARK: - CompLevel

    @Test func compLevel_sortOrder() {
        #expect(CompLevel.qm.sortOrder == 0)
        #expect(CompLevel.ef.sortOrder == 1)
        #expect(CompLevel.qf.sortOrder == 2)
        #expect(CompLevel.sf.sortOrder == 3)
        #expect(CompLevel.f.sortOrder == 4)
    }

    @Test func compLevel_level() {
        #expect(CompLevel.qm.level == "Qualification")
        #expect(CompLevel.ef.level == "Octofinals")
        #expect(CompLevel.qf.level == "Quarterfinals")
        #expect(CompLevel.sf.level == "Semifinals")
        #expect(CompLevel.f.level == "Finals")
    }

    @Test func compLevel_levelShort() {
        #expect(CompLevel.qm.levelShort == "Quals")
        #expect(CompLevel.ef.levelShort == "Eighths")
        #expect(CompLevel.qf.levelShort == "Quarters")
        #expect(CompLevel.sf.levelShort == "Semis")
        #expect(CompLevel.f.levelShort == "Finals")
    }

    // MARK: - compLevelString / compLevelSortOrder

    @Test func compLevelString_forwardsRawValue() {
        let match = makeMatch(compLevel: .qm)
        #expect(match.compLevelString == "qm")
    }

    @Test func compLevelSortOrder_forwardsCompLevelSortOrder() {
        let match = makeMatch(compLevel: .sf)
        #expect(match.compLevelSortOrder == 3)
    }

    // MARK: - friendlyName

    @Test func friendlyName_qualification() {
        let match = makeMatch(compLevel: .qm, setNumber: 1, matchNumber: 73)
        #expect(match.friendlyName == "Quals 73")
    }

    @Test func friendlyName_elimination() {
        let match = makeMatch(compLevel: .ef, setNumber: 2, matchNumber: 73)
        #expect(match.friendlyName == "Eighths 2-73")
    }

    // MARK: - startTime priority (actual > predicted > scheduled)

    @Test func startTime_prefersActual() {
        let match = makeMatch(
            compLevel: .qm,
            time: 1_520_090_779,
            actualTime: 1_520_090_781,
            predictedTime: 1_520_090_780
        )
        #expect(match.startTime == 1_520_090_781)
    }

    @Test func startTime_fallsBackToPredicted() {
        let match = makeMatch(
            compLevel: .qm,
            time: 1_520_090_779,
            actualTime: nil,
            predictedTime: 1_520_090_780
        )
        #expect(match.startTime == 1_520_090_780)
    }

    @Test func startTime_fallsBackToScheduled() {
        let match = makeMatch(compLevel: .qm, time: 1_520_090_779)
        #expect(match.startTime == 1_520_090_779)
    }

    @Test func startTime_nilWhenAllAbsent() {
        let match = makeMatch(compLevel: .qm)
        #expect(match.startTime == nil)
    }

    // MARK: - Alliance team keys

    @Test func redAllianceTeamKeys_forwardsRedSlot() {
        let match = makeMatch(
            compLevel: .qm,
            red: ["frc2337", "frc7332", "frc3333"],
            blue: ["frc254"]
        )
        #expect(match.redAllianceTeamKeys == ["frc2337", "frc7332", "frc3333"])
    }

    @Test func blueAllianceTeamKeys_forwardsBlueSlot() {
        let match = makeMatch(
            compLevel: .qm,
            red: ["frc254"],
            blue: ["frc2337", "frc7332", "frc3333"]
        )
        #expect(match.blueAllianceTeamKeys == ["frc2337", "frc7332", "frc3333"])
    }

    @Test func allTeamKeys_concatenatesRedAndBlue() {
        let match = makeMatch(
            compLevel: .qm,
            red: ["frc1"],
            blue: ["frc2", "frc3"]
        )
        #expect(match.allTeamKeys == ["frc1", "frc2", "frc3"])
    }

    @Test func dqTeamKeys_concatenatesRedAndBlue() {
        let match = makeMatch(
            compLevel: .qm,
            redDQ: ["frc7332"],
            blueDQ: ["frc5555"]
        )
        #expect(match.dqTeamKeys == ["frc7332", "frc5555"])
    }

    // MARK: - year / eventKeyFromMatchKey

    @Test func year_parsedFromKeyPrefix() {
        let match = makeMatch(key: "2018miket_qm1", compLevel: .qm)
        #expect(match.year == 2018)
    }

    @Test func eventKeyFromMatchKey_parsedFromKey() {
        let match = makeMatch(key: "2018miket_qm1", compLevel: .qm)
        #expect(match.eventKeyFromMatchKey == "2018miket")
    }

    // MARK: - MatchKey helpers

    @Test func matchKey_year() {
        #expect(MatchKey.year(from: "2018miket_qm1") == 2018)
    }

    @Test func matchKey_eventKey() {
        #expect(MatchKey.eventKey(from: "2018miket_qm1") == "2018miket")
    }

    // MARK: - winningAllianceString

    @Test func winningAllianceString_empty() {
        let match = makeMatch(compLevel: .qm, winningAlliance: ._empty_)
        #expect(match.winningAllianceString == "")
    }

    @Test func winningAllianceString_red() {
        let match = makeMatch(compLevel: .qm, winningAlliance: .red)
        #expect(match.winningAllianceString == "red")
    }

    // MARK: - Test helpers

    private func makeMatch(
        key: String = "2018miket_qm1",
        compLevel: CompLevel,
        setNumber: Int = 1,
        matchNumber: Int = 1,
        red: [String] = [],
        blue: [String] = [],
        redDQ: [String] = [],
        blueDQ: [String] = [],
        winningAlliance: Match.WinningAlliancePayload = ._empty_,
        time: Int64? = nil,
        actualTime: Int64? = nil,
        predictedTime: Int64? = nil
    ) -> Match {
        Match(
            key: key,
            compLevel: compLevel,
            setNumber: setNumber,
            matchNumber: matchNumber,
            alliances: Match.AlliancesPayload(
                red: MatchAlliance(
                    score: 0,
                    teamKeys: red,
                    surrogateTeamKeys: [],
                    dqTeamKeys: redDQ
                ),
                blue: MatchAlliance(
                    score: 0,
                    teamKeys: blue,
                    surrogateTeamKeys: [],
                    dqTeamKeys: blueDQ
                )
            ),
            winningAlliance: winningAlliance,
            eventKey: "2018miket",
            time: time,
            actualTime: actualTime,
            predictedTime: predictedTime,
            videos: []
        )
    }
}
