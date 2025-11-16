//
//  SearchServiceEnvironmentKey.swift
//  TBA
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import TBAAPI
import SwiftUI

private struct SearchServiceEnvironmentKey: EnvironmentKey {
    static let defaultValue: SearchService = SearchService(api: TBAAPI(apiKey: Secrets().tbaAPIKey))
}

extension EnvironmentValues {
    var searchService: SearchService {
        get { self[SearchServiceEnvironmentKey.self] }
        set { self[SearchServiceEnvironmentKey.self] = newValue }
    }
}

extension Scene {
    @discardableResult
    func searchService(searchService: SearchService) -> some Scene {
        self
            .environment(\.searchService, searchService)
    }
}

extension View {
    @discardableResult
    func searchService(searchService: SearchService) -> some View {
        self
            .environment(\.searchService, searchService)
    }
}
