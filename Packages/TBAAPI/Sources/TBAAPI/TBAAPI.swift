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

public struct TBAAPI {

    public static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    // TODO: Add a way to set/change the cache strategy for debugging

    public let client: Client

    public init(apiKey: String) {
        let serverURL = (try? Servers.Server1.url()) ?? APIConstants.baseURL

        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = [
            "X-TBA-Auth-Key": apiKey,
        ]

        #if DEBUG
        configuration.urlCache!.removeAllCachedResponses()
        #endif

        self.client = Client(
            serverURL: serverURL,
            transport: URLSessionTransport(configuration: .init(
                session: URLSession(configuration: configuration)
            ))
        )
    }
}
