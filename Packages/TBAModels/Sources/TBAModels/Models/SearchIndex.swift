//
//  SearchIndex.swift
//  TBAModels
//
//  Created by Zachary Orr on 4/19/25.
//

public struct SearchIndex: Decodable, Sendable {
    public var teams: [SearchTeam]
    public var events: [SearchEvent]

    public struct SearchEvent: Decodable, Sendable {
        public var key: String
        public var name: String
    }

    public struct SearchTeam: Decodable, Sendable {
        public var key: String
        public var nickname: String
    }
}
