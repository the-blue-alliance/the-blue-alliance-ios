//
//  TBAAPI.swift
//
//
//  Created by Zachary Orr on 8/13/24.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

private enum APIConstants {
    static let baseURL = URL(string: "https://www.thebluealliance.com/api/v3/")!
}

public typealias TBAAPI = Client

public extension TBAAPI {
    init(apiKey: String, transport: (any ClientTransport)? = nil) {
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

        self.init(
            serverURL: serverURL,
            transport: transport ?? URLSessionTransport(configuration: .init(
                session: URLSession(configuration: configuration),
            )),
        )
    }
}
