//
//  WebcastTests.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/19/25.
//

import Testing
import Foundation
@testable import TBAModels

@Suite("Webcast API Types")
struct WebcastTypeAPI {
    @Test func apiTypesSupported() async throws {
        for webcastType in Components.Schemas.Webcast._typePayload.allCases {
            #expect(Webcast.WebcastType(rawValue: webcastType.rawValue) != nil, "WebcastType.\(webcastType) is unsupported")
        }
    }
}

@Suite("Webcast Decoding Tests")
struct WebcastDecodingTests {

    private static func decode(_ json: Data) throws -> Webcast {
        let decoder = JSONDecoder()
        decoder .dateDecodingStrategy = .formatted(TBAAPI.dateFormatter)
        return try decoder.decode(Webcast.self, from: json)
    }

    @Test
    func decodeWebcast() throws {
        let json = """
        {
          "type": "youtube",
          "channel": "somechannel123",
          "date": "2023-10-27",
          "file": null
        }
        """.data(using: .utf8)!

        let webcast = try WebcastDecodingTests.decode(json)

        #expect(webcast.type == .youtube)
        #expect(webcast.channel == "somechannel123")

        let expectedDate = TBAAPI.dateFormatter.date(from: "2023-10-27")
        #expect(Calendar.current.isDate(webcast.date!, inSameDayAs: expectedDate!))
        #expect(webcast.file == nil)
    }

    @Test
    func decodeWebcastUnknownType() throws {
        let json = """
        {
          "type": "newstreamingservice",
          "channel": "somechannel123",
          "date": "2023-10-27",
          "file": null
        }
        """.data(using: .utf8)!

        #expect(throws: (any Error).self) {
            try WebcastDecodingTests.decode(json)
        }
    }

    @Test
    func decodeWebcastNullOptionals() throws {
        let json = """
        {
          "type": "twitch",
          "channel": "anotherchannel",
          "date": null,
          "file": null
        }
        """.data(using: .utf8)!

        let webcast = try WebcastDecodingTests.decode(json)

        #expect(webcast.type == .twitch)
        #expect(webcast.channel == "anotherchannel")
        #expect(webcast.date == nil)
        #expect(webcast.file == nil)
    }

    @Test
    func testWebcastMissingOptionals() throws {
        let json = """
        {
          "type": "twitch",
          "channel": "anotherchannel"
        }
        """.data(using: .utf8)!

        let webcast = try WebcastDecodingTests.decode(json)

        #expect(webcast.type == .twitch)
        #expect(webcast.channel == "anotherchannel")
        #expect(webcast.date == nil)
        #expect(webcast.file == nil)
    }

    @Test
    func decodeWebcastFile() throws {
        let json = """
        {
          "type": "rtmp",
          "channel": "sargasso-4.arc.nasa.gov/live/",
          "file": "stlouis"
        }
        """.data(using: .utf8)!

        let webcast = try WebcastDecodingTests.decode(json)

        #expect(webcast.type == .rtmp)
        #expect(webcast.channel == "sargasso-4.arc.nasa.gov/live/")
        #expect(webcast.date == nil)
        #expect(webcast.file == "stlouis")
    }
}
