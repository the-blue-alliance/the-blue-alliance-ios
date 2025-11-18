//
//  EventView.swift
//  TBA
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI

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
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                VStack(spacing: 0) {
                    NavigationRowView(
                        icon: "person.2.fill",
                        iconColor: .blue,
                        title: "Teams") {
                            Text("Teams")
                        }
                    NavigationRowView(
                        icon: "chart.bar.horizontal.page.fill",
                        iconColor: .blue,
                        title: "Matches") {
                            Text("Matches")
                        }
                    NavigationRowView(
                        icon: "text.line.first.and.arrowtriangle.forward",
                        iconColor: .blue,
                        title: "Rankings") {
                            Text("Rankings")
                        }
                    NavigationRowView(
                        icon: "person.3.fill",
                        iconColor: .blue,
                        title: "Alliances") {
                            Text("Aliances")
                        }
                    NavigationRowView(
                        icon: "chart.bar.xaxis.ascending",
                        iconColor: .blue,
                        title: "Insights") {
                            Text("Insights")
                        }
                    NavigationRowView(
                        icon: "trophy.fill",
                        iconColor: .yellow,
                        title: "Awards") {
                            Text("Awards")
                        }
                }

                /*
                VStack(spacing: 0) {
                    NavigationRowView(
                        icon: "person.2.fill",
                        iconColor: Color.blue,
                        title: "Teams",
                        count: nil
                    ) {
                        Text("Teams View")
                    }

                    Divider()
                        .padding(.leading, 64)

                    NavigationRowView(
                        icon: "person.2.fill",
                        iconColor: Color.blue,
                        title: "Teams",
                        count: nil
                    ) {
                        Text("Teams View")
                    }
                }
                */

                Divider()
            }
        }
        .refreshable {
            // Pass
        }
        .task {
            await refresh()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(event.displayNameWithYear)
                    .font(.headline)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .sharedBackgroundVisibility(.hidden)
            // TODO: myTBA bits here
        }
    }

    private func refresh() async {
        error = nil
        isInitialLoading = true
        // defer { isInitialLoading = false }
        do {
            let response = try await api.getEvent(.init(path: .init(eventKey: event.key)))
            guard !Task.isCancelled else { return }
            self.event = try response.ok.body.json
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

                if let count = count {
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
