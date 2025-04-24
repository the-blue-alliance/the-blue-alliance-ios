//
//  Webcast.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct Webcast: Decodable, Sendable {
    public var type: WebcastType
    public var channel: String
    public var file: String?
    public var date: Date?

    public enum WebcastType: String, Decodable, Sendable {
        case youtube
        case twitch
        case ustream
        case iframe
        case html5
        case rtmp
        case livestream
        case directLink = "direct_link"
        case mms
        case justin
        case stemtv
        case dacast
    }
}

extension Webcast: Equatable, Hashable {}
