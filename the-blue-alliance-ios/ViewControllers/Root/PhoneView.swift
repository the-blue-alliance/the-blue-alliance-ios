//
//  PhoneView.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI

enum TBATab: CaseIterable, Identifiable {

    var id: Self {
        return self
    }

    case events
    case districts
    case insights
    case myTBA

    var title: String {
        switch self {
        case .events:
            return "Events"
        case .districts:
            return "Districts"
        case .insights:
            return "Insights"
        case .myTBA:
            return "myTBA"
        }
    }

    var image: String {
        switch self {
        case .events:
            return "calendar"
        case .districts:
            return "circle.hexagongrid"
        case .insights:
            return "chart.bar"
        case .myTBA:
            return "star"
        }
    }
}

struct PhoneView: View {

    // @State private var searchIndex: SearchIndex?
    @State private var selection: TBATab! = .events

    @State private var searchText: String = ""
    @State private var searchScope = SearchScope.all

    var body: some View {
        TabView {
            Tab(TBATab.events.title, systemImage: TBATab.events.image) {
                SeasonEventsView()
            }
            Tab(TBATab.districts.title, systemImage: TBATab.districts.image) {
                // TODO: Districts
                // DistrictsRootView()
            }
            Tab(TBATab.insights.title, systemImage: TBATab.insights.image) {
                // TODO: Insights
                // InsightsView()
            }
            Tab(TBATab.myTBA.title, systemImage: TBATab.myTBA.image) {
                Text("myTBA")
            }
            Tab(role: .search) {
                NavigationStack {
                    Text("Search")
                }
            }
        }
        .searchable(text: $searchText)
        .searchScopes($searchScope, activation: .onSearchPresentation) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Text(scope.rawValue.capitalized)
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(.tabBarTintColor)
    }
}

#Preview {
    PhoneView()
}

