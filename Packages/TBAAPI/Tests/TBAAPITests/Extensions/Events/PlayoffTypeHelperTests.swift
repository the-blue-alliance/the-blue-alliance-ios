import Testing
@testable import TBAAPI

struct PlayoffTypeHelperTests {

    // MARK: - Double Elim 8 (2023+)

    @Test func doubleElim8_firstFourSemisAreRound1() {
        for set in 1...4 {
            #expect(PlayoffTypeHelper.doubleElimRound(compLevel: .sf, setNumber: set) == .round1)
        }
    }

    @Test func doubleElim8_sets5to8AreRound2() {
        for set in 5...8 {
            #expect(PlayoffTypeHelper.doubleElimRound(compLevel: .sf, setNumber: set) == .round2)
        }
    }

    @Test func doubleElim8_sets9to10AreRound3() {
        #expect(PlayoffTypeHelper.doubleElimRound(compLevel: .sf, setNumber: 9) == .round3)
        #expect(PlayoffTypeHelper.doubleElimRound(compLevel: .sf, setNumber: 10) == .round3)
    }

    @Test func doubleElim8_sets11to12AreRound4() {
        #expect(PlayoffTypeHelper.doubleElimRound(compLevel: .sf, setNumber: 11) == .round4)
        #expect(PlayoffTypeHelper.doubleElimRound(compLevel: .sf, setNumber: 12) == .round4)
    }

    @Test func doubleElim8_set13IsRound5() {
        #expect(PlayoffTypeHelper.doubleElimRound(compLevel: .sf, setNumber: 13) == .round5)
    }

    @Test func doubleElim8_finalsCompLevelAlwaysFinals() {
        for match in 1...6 {
            #expect(PlayoffTypeHelper.doubleElimRound(compLevel: .f, setNumber: match) == .finals)
        }
    }

    // MARK: - Double Elim 4

    @Test func doubleElim4_firstTwoSetsAreRound1() {
        #expect(PlayoffTypeHelper.doubleElim4Round(compLevel: .sf, setNumber: 1) == .round1)
        #expect(PlayoffTypeHelper.doubleElim4Round(compLevel: .sf, setNumber: 2) == .round1)
    }

    @Test func doubleElim4_sets3to4AreRound2() {
        #expect(PlayoffTypeHelper.doubleElim4Round(compLevel: .sf, setNumber: 3) == .round2)
        #expect(PlayoffTypeHelper.doubleElim4Round(compLevel: .sf, setNumber: 4) == .round2)
    }

    @Test func doubleElim4_set5IsRound3() {
        #expect(PlayoffTypeHelper.doubleElim4Round(compLevel: .sf, setNumber: 5) == .round3)
    }

    @Test func doubleElim4_finals() {
        #expect(PlayoffTypeHelper.doubleElim4Round(compLevel: .f, setNumber: 1) == .finals)
    }

    // MARK: - Legacy Double Elim 8

    @Test func legacyDE8_efSets1to4AreRound1() {
        for set in 1...4 {
            #expect(
                PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .ef, setNumber: set) == .round1
            )
        }
    }

    @Test func legacyDE8_efSets5to6AreRound2() {
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .ef, setNumber: 5) == .round2)
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .ef, setNumber: 6) == .round2)
    }

    @Test func legacyDE8_qfSets1to2AreRound2_andSets3to4AreRound3() {
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .qf, setNumber: 1) == .round2)
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .qf, setNumber: 2) == .round2)
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .qf, setNumber: 3) == .round3)
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .qf, setNumber: 4) == .round3)
    }

    @Test func legacyDE8_sfIsRound4() {
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .sf, setNumber: 1) == .round4)
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .sf, setNumber: 2) == .round4)
    }

    @Test func legacyDE8_fSet1IsRound5_thenFinals() {
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .f, setNumber: 1) == .round5)
        #expect(PlayoffTypeHelper.legacyDoubleElimRound(compLevel: .f, setNumber: 2) == .finals)
    }

    @Test func legacyDE8_bracketSplit() {
        // ef 1..4 = upper; ef 5..6 = lower
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .ef, setNumber: 1) == .winner)
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .ef, setNumber: 4) == .winner)
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .ef, setNumber: 5) == .loser)
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .ef, setNumber: 6) == .loser)
        // qf 1..2 = upper; qf 3..4 = lower
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .qf, setNumber: 2) == .winner)
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .qf, setNumber: 3) == .loser)
        // sf 1 = upper; sf 2 = lower
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .sf, setNumber: 1) == .winner)
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .sf, setNumber: 2) == .loser)
        // f 1 = lower-bracket final; f 2 = overall final (upper side)
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .f, setNumber: 1) == .loser)
        #expect(PlayoffTypeHelper.legacyDoubleElimBracket(compLevel: .f, setNumber: 2) == .winner)
    }

}
