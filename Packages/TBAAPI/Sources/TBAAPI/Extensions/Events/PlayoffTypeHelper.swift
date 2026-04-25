import Foundation

// Pure match → round mapping for playoff formats. Ported from
// https://github.com/the-blue-alliance/the-blue-alliance/blob/main/src/backend/common/helpers/playoff_type_helper.py.
//
// Note: `EliminationAlliance.status.doubleElimRound` tells us where an
// *alliance* stands today, not which round a given *match* belongs to —
// that's why we still need these per-match helpers.
public enum PlayoffTypeHelper {

    // FIRST's 2023+ 8-team double elimination. Every pre-finals match is
    // stored as `sf` with set 1..13; finals are BO3 stored as `f` set 1
    // matches 1..3.
    public static func doubleElimRound(compLevel: CompLevel, setNumber: Int) -> DoubleElimRound {
        if compLevel == .f { return .finals }
        switch setNumber {
        case ...4: return .round1
        case ...8: return .round2
        case ...10: return .round3
        case ...12: return .round4
        default: return .round5
        }
    }

    // 4-team double elimination (districts w/ divisions). 5 pre-finals `sf`
    // sets (each match_number 1), then BO3 finals as `f` set 1 matches 1..3.
    public static func doubleElim4Round(compLevel: CompLevel, setNumber: Int) -> DoubleElimRound {
        if compLevel == .f { return .finals }
        switch setNumber {
        case ...2: return .round1
        case ...4: return .round2
        default: return .round3
        }
    }

    // Pre-2023 8-team double elimination. Keyed by (level, set) across ef/qf/sf/f.
    // This is the format where matches of the same comp level split across
    // the upper and lower brackets.
    public static func legacyDoubleElimRound(compLevel: CompLevel, setNumber: Int)
        -> DoubleElimRound
    {
        switch (compLevel, setNumber) {
        case (.ef, let s) where s <= 4: return .round1
        case (.ef, _): return .round2
        case (.qf, let s) where s <= 2: return .round2
        case (.qf, _): return .round3
        case (.sf, _): return .round4
        case (.f, 1): return .round5
        default: return .finals
        }
    }

    // Legacy 8-team double elim: which side of the bracket a given match lives in.
    // In the legacy layout, `f` set 1 is the lower-bracket final; `f` set 2 is the
    // overall final.
    public static func legacyDoubleElimBracket(compLevel: CompLevel, setNumber: Int)
        -> LegacyDoubleElimBracket
    {
        switch (compLevel, setNumber) {
        case (.ef, let s) where s <= 4: return .winner
        case (.ef, _): return .loser
        case (.qf, let s) where s <= 2: return .winner
        case (.qf, _): return .loser
        case (.sf, 1): return .winner
        case (.sf, _): return .loser
        case (.f, 1): return .loser
        default: return .winner
        }
    }

}

public enum LegacyDoubleElimBracket: String, Hashable, Sendable {
    case winner
    case loser
}
