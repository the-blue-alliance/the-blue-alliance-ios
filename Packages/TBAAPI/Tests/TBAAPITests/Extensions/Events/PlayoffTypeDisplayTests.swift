import Testing

@testable import TBAAPI

struct DoubleElimRoundDisplayTests {

    @Test func title_isRawValue() {
        #expect(DoubleElimRound.round1.title == "Round 1")
        #expect(DoubleElimRound.round2.title == "Round 2")
        #expect(DoubleElimRound.round3.title == "Round 3")
        #expect(DoubleElimRound.round4.title == "Round 4")
        #expect(DoubleElimRound.round5.title == "Round 5")
        #expect(DoubleElimRound.finals.title == "Finals")
    }

    @Test func shortTitle_rounds() {
        #expect(DoubleElimRound.round1.shortTitle == "R1")
        #expect(DoubleElimRound.round2.shortTitle == "R2")
        #expect(DoubleElimRound.round3.shortTitle == "R3")
        #expect(DoubleElimRound.round4.shortTitle == "R4")
        #expect(DoubleElimRound.round5.shortTitle == "R5")
    }

    @Test func shortTitle_finals() {
        #expect(DoubleElimRound.finals.shortTitle == "F")
    }

    @Test func sortOrder_isAscendingFromRound1ToFinals() {
        let cases: [DoubleElimRound] = [.round1, .round2, .round3, .round4, .round5, .finals]
        let orders = cases.map(\.sortOrder)
        #expect(orders == [0, 1, 2, 3, 4, 5])
    }
}

struct LegacyDoubleElimBracketDisplayTests {

    @Test func title() {
        #expect(LegacyDoubleElimBracket.winner.title == "Upper Bracket")
        #expect(LegacyDoubleElimBracket.loser.title == "Lower Bracket")
    }

    @Test func sortOrder() {
        #expect(LegacyDoubleElimBracket.winner.sortOrder == 0)
        #expect(LegacyDoubleElimBracket.loser.sortOrder == 1)
    }
}
