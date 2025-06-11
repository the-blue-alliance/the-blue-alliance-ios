//
//  Team+TBA.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/23/25.
//

public protocol Team: Locatable {
    var key: String { get }
    var teamNumber: Int { get }
    var nickname: String { get }
    var name: String { get }
    var city: String? { get }
    var stateProv: String? { get }
    var country: String? { get }
}

extension TeamFull: Team {}
extension TeamSimple: Team {}

// TODO: Write a little guy to hack our schema gen for teams/all
