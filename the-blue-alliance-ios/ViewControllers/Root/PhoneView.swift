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

    @Environment(\.api) private var api

    // @State private var searchIndex: SearchIndex?
    @State private var selection: TBATab! = .events

    @State private var searchText: String = ""
    @State private var searchScope = SearchScope.all

    var body: some View {
        TabView {
            Tab("Events", systemImage: "calendar") {
                // TODO: Events
                // EventsRootView()
            }
            Tab("Districts", systemImage: "circle.hexagongrid") {
                // TODO: Districts
                // DistrictsRootView()
            }
            Tab("Insights", systemImage: "chart.bar") {
                // TODO: Insights
                // InsightsView()
            }
            Tab("myTBA", systemImage: "star") {
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

