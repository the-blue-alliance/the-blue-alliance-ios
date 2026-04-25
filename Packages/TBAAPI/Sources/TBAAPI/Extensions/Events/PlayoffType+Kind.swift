import Foundation

// The OpenAPI-generated `PlayoffType` has raw integer cases (`_0`, `_1`, …,
// `_11`) because `namingStrategy: idiomatic` doesn't honor `x-enum-varnames`
// on integer enums. `Kind` gives callers a readable enum to switch over
// without scattering magic integer names across the codebase.
extension PlayoffType {

    public enum Kind: Hashable, Sendable, CaseIterable {
        case bracket8Team
        case bracket16Team
        case bracket4Team
        case bracket2Team
        case averageScore8Team
        case roundRobin6Team
        case legacyDoubleElim8Team
        case doubleElim8Team
        case doubleElim4Team
        case bo5Finals
        case bo3Finals
        case custom
    }

    public var kind: Kind {
        switch self {
        case ._0: return .bracket8Team
        case ._1: return .bracket16Team
        case ._2: return .bracket4Team
        case ._9: return .bracket2Team
        case ._3: return .averageScore8Team
        case ._4: return .roundRobin6Team
        case ._5: return .legacyDoubleElim8Team
        case ._10: return .doubleElim8Team
        case ._11: return .doubleElim4Team
        case ._6: return .bo5Finals
        case ._7: return .bo3Finals
        case ._8: return .custom
        }
    }

    // Named accessors mirroring `Kind`'s cases for use at call sites
    // (`event.playoffType == .roundRobin6Team`). Switch statements still need
    // `.kind` since static lets aren't pattern-matchable.
    public static let bracket8Team: PlayoffType = ._0
    public static let bracket16Team: PlayoffType = ._1
    public static let bracket4Team: PlayoffType = ._2
    public static let bracket2Team: PlayoffType = ._9
    public static let averageScore8Team: PlayoffType = ._3
    public static let roundRobin6Team: PlayoffType = ._4
    public static let legacyDoubleElim8Team: PlayoffType = ._5
    public static let doubleElim8Team: PlayoffType = ._10
    public static let doubleElim4Team: PlayoffType = ._11
    public static let bo5Finals: PlayoffType = ._6
    public static let bo3Finals: PlayoffType = ._7
    public static let custom: PlayoffType = ._8
}
