//
//  PadRootView.swift
//  The Blue Alliance
//
//  Created by Zachary Orr on 6/10/21.
//  Copyright © 2021 The Blue Alliance. All rights reserved.
//

import TBAData
import MyTBAKit
import Photos
import SwiftUI

enum Root: Int, CaseIterable {
    case home
    case events
    case teams
    case districts
    case gameDay

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .events:
            return "Events"
        case .teams:
            return "Teams"
        case .districts:
            return "Districts"
        case .gameDay:
            return "GameDay"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            return "house"
        case .events:
            return "calendar"
        case .teams:
            return "person.2"
        case .districts:
            return "circles.hexagongrid"
        case .gameDay:
            return "video"
        }
    }
}

struct PadRootView: View {

    var body: some View {
        NavigationView {
            List {
                ForEach(Root.allCases, id: \.self) { tab in
                    NavigationLink(destination: Text(tab.title)) {
                        Label {
                            Text(tab.title)
                        } icon: {
                            Image(systemName: tab.systemImage)
                        }.font(.body)
                    }
                }
            }.navigationTitle("The Blue Alliance")
            PlaceholderView()
        }
    }

}
