//
//  SearchView.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI

enum SearchScope: String, CaseIterable {
    case all, events, teams
}

struct SearchView: View {

    @Environment(\.api) private var api
    @Environment(\.refresh) private var refresh
    @Environment(\.searchService) private var searchService

    @State private var searchText: String = ""
    @State private var searchScope = SearchScope.all
    @State private var searchIndex: SearchIndex?

    var items: [SearchScope: [String]] {
        let items: [SearchScope: [String]] = [
            .teams: searchIndex?.teams.map { $0.nickname } ?? [],
            .events: searchIndex?.events.map { $0.name } ?? []
        ]
        if searchText.isEmpty {
            return items
        } else {
            return [
                .teams: items[.teams]!.filter { $0.starts(with: searchText) },
                .events: items[.events]!.filter { $0.starts(with: searchText) }
            ]
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(["abc", "def"], id: \.self) { item in
                    Text(item)
                }
            }
            .navigationTitle("Search")
            // .toolbarBackground(Color.navigationBarColor, for: .navigationBar)
            // .toolbarBackground(.visible, for: .navigationBar)
            // .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $searchText, prompt: "Search for Events or Teams")
        .searchScopes($searchScope, activation: .onSearchPresentation) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Text(scope.rawValue.capitalized)
            }
        }
    }

    private func refresh() async {
        do {
            try await searchService.refresh()
        } catch {
            // TODO: Show an error here
        }
    }
}
