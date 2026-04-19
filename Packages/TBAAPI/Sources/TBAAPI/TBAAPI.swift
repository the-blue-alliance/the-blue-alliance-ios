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

public final class TBAAPI {

    public enum CachePolicy: String, CaseIterable, Sendable {
        case `default`
        case bypass
    }

    public static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    private final class Box {
        var client: Client
        init(client: Client) { self.client = client }
    }

    private let apiKey: String
    private let box: Box
    public private(set) var cachePolicy: CachePolicy
    // Additional `URLProtocol` subclasses to layer onto the underlying session.
    // Used by the screenshot-mocking layer to swap a `FixtureURLProtocol` in
    // without touching production code paths. Defaults to nil so production
    // keeps the stock URLSession configuration.
    private let protocolClasses: [AnyClass]?

    public var client: Client { box.client }

    public init(apiKey: String, cachePolicy: CachePolicy = .default, protocolClasses: [AnyClass]? = nil) {
        self.apiKey = apiKey
        self.cachePolicy = cachePolicy
        self.protocolClasses = protocolClasses
        self.box = Box(client: Self.makeClient(apiKey: apiKey, policy: cachePolicy, protocolClasses: protocolClasses))
    }

    public func setCachePolicy(_ policy: CachePolicy) {
        guard policy != cachePolicy else { return }
        cachePolicy = policy
        box.client = Self.makeClient(apiKey: apiKey, policy: policy, protocolClasses: protocolClasses)
    }

    public func clearCache() {
        URLCache.shared.removeAllCachedResponses()
    }

    private static func makeClient(apiKey: String, policy: CachePolicy, protocolClasses: [AnyClass]? = nil) -> Client {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["X-TBA-Auth-Key": apiKey]
        switch policy {
        case .default:
            configuration.requestCachePolicy = .useProtocolCachePolicy
        case .bypass:
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        }
        if let protocolClasses {
            configuration.protocolClasses = protocolClasses
        }

        let serverURL = (try? Servers.Server1.url()) ?? APIConstants.baseURL
        return Client(
            serverURL: serverURL,
            transport: URLSessionTransport(configuration: .init(
                session: URLSession(configuration: configuration)
            ))
        )
    }
}
