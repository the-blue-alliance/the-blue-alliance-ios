import Foundation

extension PlayoffType {

    public var isBracket: Bool {
        switch kind {
        case .bracket2Team, .bracket4Team, .bracket8Team, .bracket16Team:
            return true
        default:
            return false
        }
    }

    public var isDoubleElim: Bool {
        switch kind {
        case .legacyDoubleElim8Team, .doubleElim8Team, .doubleElim4Team:
            return true
        default:
            return false
        }
    }

    public var isRoundRobin: Bool { kind == .roundRobin6Team }

    public var isFinalsOnly: Bool {
        kind == .bo3Finals || kind == .bo5Finals
    }

    // Human-readable name, verbatim from TBA's TYPE_NAMES.
    public var displayName: String {
        switch kind {
        case .bracket8Team: return "Elimination Bracket (8 Alliances)"
        case .bracket16Team: return "Elimination Bracket (16 Alliances)"
        case .bracket4Team: return "Elimination Bracket (4 Alliances)"
        case .bracket2Team: return "Elimination Bracket (2 Alliances)"
        case .averageScore8Team: return "Average Score (8 Alliances)"
        case .roundRobin6Team: return "Round Robin (6 Alliances)"
        case .doubleElim8Team: return "Double Elimination Bracket (8 Alliances)"
        case .doubleElim4Team: return "Double Elimination Bracket (4 Alliances)"
        case .legacyDoubleElim8Team: return "Legacy Double Elimination Bracket (8 Alliances)"
        case .bo3Finals: return "Best of 3 Finals"
        case .bo5Finals: return "Best of 5 Finals"
        case .custom: return "Custom"
        }
    }
}

extension DoubleElimRound {

    // The raw string already reads "Round 1", "Finals", etc.
    public var title: String { rawValue }

    public var sortOrder: Int {
        switch self {
        case .round1: return 0
        case .round2: return 1
        case .round3: return 2
        case .round4: return 3
        case .round5: return 4
        case .finals: return 5
        }
    }
}

extension LegacyDoubleElimBracket {

    public var title: String {
        switch self {
        case .winner: return "Upper Bracket"
        case .loser: return "Lower Bracket"
        }
    }

    public var sortOrder: Int {
        switch self {
        case .winner: return 0
        case .loser: return 1
        }
    }
}
