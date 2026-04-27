import Foundation
import TBAAPI

enum MatchSection: Hashable {
    case qualification
    case compLevel(CompLevel)
    case doubleElimRound(DoubleElimRound)
    case legacyDoubleElim(LegacyDoubleElimBracket, CompLevel)
    case roundRobinSemifinals
    case roundRobinFinals

    var title: String {
        switch self {
        case .qualification:
            return "Qualifications"
        case .compLevel(let level):
            return level.level
        case .doubleElimRound(let round):
            return round.title
        case .legacyDoubleElim(let bracket, let level):
            return "\(bracket.title) — \(level.levelShort)"
        case .roundRobinSemifinals:
            return "Round Robin Semifinals"
        case .roundRobinFinals:
            return "Finals"
        }
    }

    // The trailing sub-order keeps multi-part sections (legacy DE
    // winner/loser across comp levels) ordered within their bucket.
    var sortOrder: (Int, Int) {
        switch self {
        case .qualification:
            return (0, 0)
        case .compLevel(let level):
            return (10, level.sortOrder)
        case .doubleElimRound(let round):
            return (20, round.sortOrder)
        case .legacyDoubleElim(let bracket, let level):
            return (30 + bracket.sortOrder, level.sortOrder)
        case .roundRobinSemifinals:
            return (40, 0)
        case .roundRobinFinals:
            return (50, 0)
        }
    }
}

extension MatchSection: Comparable {
    static func < (lhs: MatchSection, rhs: MatchSection) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

extension MatchSection: TableSectionTitleProviding {
    var headerTitle: String? { title }
}

extension MatchSection {

    static func section(for match: Match, playoffType: PlayoffType?) -> MatchSection {
        if match.compLevel == .qm { return .qualification }

        guard let playoffType else {
            return .compLevel(match.compLevel)
        }

        switch playoffType.kind {
        case .doubleElim8Team:
            return .doubleElimRound(
                PlayoffTypeHelper.doubleElimRound(
                    compLevel: match.compLevel,
                    setNumber: match.setNumber
                )
            )
        case .doubleElim4Team:
            return .doubleElimRound(
                PlayoffTypeHelper.doubleElim4Round(
                    compLevel: match.compLevel,
                    setNumber: match.setNumber
                )
            )
        case .legacyDoubleElim8Team:
            let bracket = PlayoffTypeHelper.legacyDoubleElimBracket(
                compLevel: match.compLevel,
                setNumber: match.setNumber
            )
            return .legacyDoubleElim(bracket, match.compLevel)
        case .roundRobin6Team:
            // Prelim match_numbers (1..15) overlap with finals match_numbers
            // (1..3), so we split on comp_level instead.
            return match.compLevel == .f ? .roundRobinFinals : .roundRobinSemifinals
        case .bracket2Team, .bracket4Team, .bracket8Team, .bracket16Team,
            .averageScore8Team, .bo3Finals, .bo5Finals, .custom:
            return .compLevel(match.compLevel)
        }
    }
}
