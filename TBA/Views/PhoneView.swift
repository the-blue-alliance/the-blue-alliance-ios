//
//  PhoneView.swift
//  TBA
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI

enum TBATab: CaseIterable, Identifiable {
    var id: Self {
        self
    }

    case events
    case districts
    case insights
    case myTBA

    var title: String {
        switch self {
        case .events:
            "Events"
        case .districts:
            "Districts"
        case .insights:
            "Insights"
        case .myTBA:
            "myTBA"
        }
    }

    var image: String {
        switch self {
        case .events:
            "calendar"
        case .districts:
            "circle.hexagongrid"
        case .insights:
            "chart.bar"
        case .myTBA:
            "star"
        }
    }
}

enum SearchScope: String, CaseIterable {
    case all, events, teams
}

struct PhoneView: View {
    @Environment(\.status) private var status

    // @State private var searchIndex: SearchIndex?
    @State private var selection: TBATab! = .events

    @State private var searchText: String = ""
    @State private var searchScope = SearchScope.all

    var body: some View {
        TabView {
            Tab(TBATab.events.title, systemImage: TBATab.events.image) {
                NavigationStack {
                    SeasonEventsView(year: status.currentSeason)
                }
            }
            Tab(TBATab.districts.title, systemImage: TBATab.districts.image) {
                NavigationStack {
                    DistrictsList(year: status.currentSeason)
                }
            }
            Tab(TBATab.insights.title, systemImage: TBATab.insights.image) {
                // TODO: Insights
                // InsightsView()
            }
            Tab(TBATab.myTBA.title, systemImage: TBATab.myTBA.image) {
                Text("myTBA")
            }
            Tab(role: .search) {
                // TODO: Move this to some SearchView
                NavigationStack {
                    Text("Search")
                }
                .searchable(text: $searchText)
                .searchScopes($searchScope, activation: .onSearchPresentation) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue.capitalized)
                    }
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(.tabBarTintColor)
    }
}

#Preview {
    PhoneView()
}
