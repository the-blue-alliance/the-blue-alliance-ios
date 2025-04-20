//
//  SearchService.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/19/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI
import TBAModels
import os

public class SearchService: NSObject {

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SearchService.self)
    )

    var api: TBAAPI
    var retryService: RetryService

    var searchIndex: SearchIndex? {
        didSet {
            Self.logger.debug("SearchIndex updated")
        }
    }
    var refreshTask: Task<SearchIndex, Error>?

    init(api: TBAAPI, retryService: RetryService) {
        self.api = api
        self.retryService = retryService

        super.init()
    }

    func fetchSearchIndex() async {
        defer {
            self.refreshTask = nil
        }
        self.refreshTask = Task {
            return try await api.getSearchIndex()
        }
        do {
            self.searchIndex = try await refreshTask!.value
            Self.logger.debug("Search index updated from API")
        } catch {
            Self.logger.error("Failed to update SearchIndex: \(error)")
        }
    }
}

extension SearchService: Retryable {

    var retryInterval: TimeInterval {
        return 5 * 60
    }

    func retry() {
        Task {
            await fetchSearchIndex()
        }
    }
}
