//
//  TBAAPI.swift
//
//
//  Created by Zachary Orr on 8/13/24.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

private struct APIConstants {
    static let baseURL = URL(string: "https://www.thebluealliance.com/api/v3/")!
}

public class TBAAPI {

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    // TODO: Add a way to set/change the cache strategy for debugging

    let client: Client

    public init(apiKey: String, transport: (any ClientTransport)? = nil) {
        let serverURL = (try? Servers.Server1.url()) ?? APIConstants.baseURL

        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = [
            "X-TBA-Auth-Key": apiKey,
        ]

        #if DEBUG
        if let urlCache = configuration.urlCache {
            urlCache.removeAllCachedResponses()
        }
        #endif

        self.client = Client(
            serverURL: serverURL,
            transport: transport ?? URLSessionTransport(configuration: .init(
                session: URLSession(configuration: configuration)
            ))
        )
    }

    func convertResponse<Z: Encodable, O: Decodable>(response: Z) throws -> O {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(response)

        let decoder = JSONDecoder()
        // Note to Zach: If we ever need performance here, avoiding the date conversion
        // in testing for a full year of Events saves us ~20ms (out of like ~30ms)
        decoder.dateDecodingStrategy = .formatted(TBAAPI.dateFormatter)
        return try decoder.decode(O.self, from: encoded)
    }
}
