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

    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        if isPad {
            NavigationSplitView {
                List(TBATab.allCases, selection: $selection) { (tab) in
                    NavigationLink(value: tab) {
                        HStack {
                            Image(systemName: tab.image)
                            Text(tab.title)
                        }
                    }
                }
                .navigationTitle("The Blue Alliance")
            } content: {
                switch selection {
                case .events:
                    Text("Events")
                case .districts:
                    Text("Districts")
                case .insights:
                    Text("Insights")
                case .myTBA:
                    Text("myTBA")
                case .none:
                    fatalError("No tab selected")
                }
            } detail: {
                /* column 3 */
            }
            .searchable(text: $searchText)
        } else {
            TabView {
                Tab("Events", systemImage: "calendar") {
                    NavigationStack {
                        SeasonEventsView()
                    }
                }
                Tab("Districts", systemImage: "circle.hexagongrid") {
                    Text("Districts")
                }
                Tab("Insights", systemImage: "chart.bar") {
                    Text("Insights")
                }
                Tab("myTBA", systemImage: "star") {
                    Text("myTBA")
                }
                Tab(role: .search) {
                    SearchView()
                }
                // #if !os(macOS) && !os(tvOS)
                // .customizationBehavior(.disabled, for: .sidebar, .tabBar)
                // #endif
            }
            /*
            .tabViewBottomAccessory {
                HStack {
                    Image(systemName: "baseball.diamond.bases.outs.indicator")
                    Text("Week 2")
                        .bold()
                    Image(systemName: "arrow.up")
                        .font(.caption)
                    Text("7")
                }
            }
            */
            .searchable(text: $searchText)
            .searchScopes($searchScope, activation: .onSearchPresentation) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue.capitalized)
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            // .tint(.tabBarTintColor)
        }
    }
}

#Preview {
    PhoneView()
}

