//
//  Event+PlayoffType.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/23/25.
//

extension Event.PlayoffType {
    private static let doubleElimTypes: [Event.PlayoffType] = [.legacyDoubleElim8Team, .doubleElim8Team, .doubleElim4Team]

    private static let bracketTypes: [Event.PlayoffType] = [.bracket2Team, .bracket4Team, .bracket8Team, .bracket16Team]

    public var isDoubleElimType: Bool {
        Event.PlayoffType.doubleElimTypes.contains(self)
    }

    public var isBracketType: Bool {
        Event.PlayoffType.bracketTypes.contains(self)
    }
}
