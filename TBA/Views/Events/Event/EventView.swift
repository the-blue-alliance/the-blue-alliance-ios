//
//  EventView.swift
//  TBA
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI

enum EventDetails {
    case teams
    case matches
    case rankings
    case alliances
    case insights
    case awards
}

struct EventView: View {
    @Environment(\.api) private var api

    @State var event: Event

    @State private var refreshTask: Task<Void, Never>?
    @State private var isInitialLoading = false
    @State private var error: Error?
    @State private var showYearWeekSelect = false

    // Fetch teams...
    @State private var teams: [Team]? = nil

    init(event: Event) {
        self.event = event
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                EventHeaderView(event: event)
                    .padding([.horizontal, .bottom])
                    // .frame(maxWidth: .infinity, alignment: .leading)

                // TODO: Maybe we add like, a webcasts row here?

                Divider()

                Text("Something here")

                Divider()
            }
        }
        .refreshable {
            // Pass
        }
        .task {
            await refresh()
        }
        .navigationBarTitleDisplayMode(.large) // TODO: Can we remove this?
        .navigationTitle(event.displayName)
        .toolbar {
            ToolbarItem(placement: .largeTitle) {
                Text(event.name)
                    .font(.title.bold())
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            // TODO: myTBA bits here
        }
        .toolbarBackground(Color.navigationBarColor, for: .navigationBar)
        .toolbarBackgroundVisibility(.automatic, for: .navigationBar)
    }

    private func refresh() async {
        error = nil
        isInitialLoading = true
        // defer { isInitialLoading = false }
        do {
            let response = try await api.getEvent(.init(path: .init(eventKey: event.key)))
            guard !Task.isCancelled else { return }
            event = try response.ok.body.json
        } catch {
            guard !Task.isCancelled else { return }
            self.error = error
        }
    }
}

struct NavigationRowView<Destination: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let count: String?
    let divider: Bool = true
    let destination: Destination

    init(icon: String, iconColor: Color, title: String, count: String? = nil, @ViewBuilder destination: () -> Destination) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.count = count
        self.destination = destination()
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(iconColor)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(6)
                }
                .frame(width: 32, height: 32)

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                if let count {
                    Text(count)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(height: 56)
            .background(Color(.secondarySystemGroupedBackground))
            .contentShape(Rectangle())
        }
    }
}
