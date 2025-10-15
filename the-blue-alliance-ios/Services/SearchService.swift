//
//  SearchService.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/19/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import os
import Foundation
import TBAAPI

actor SearchService {

    // TODO: We could set some timestamp to show the last time this was updated in Settings

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SearchService.self)
    )

    var api: TBAAPI

    private(set) var searchIndex: SearchIndex?
    private var refreshTask: Task<Void, Never>?

    init(api: TBAAPI) {
        self.api = api
    }

    public func refresh() async throws {
        guard refreshTask == nil else {
            return
        }
        do {
            let response = try await api.getSearchIndex()
            searchIndex = try response.ok.body.json
            Self.logger.debug("Search index updated from API")
        } catch {
            Self.logger.error("Failed to update SearchIndex: \(error)")
            throw error
        }
    }
}
