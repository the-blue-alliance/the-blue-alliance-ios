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
    var event: Event

    @State private var isStarred = true

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                EventHeaderView(event: event)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                VStack(spacing: 0) {
                    EventItemView(title: "Matches")
                    EventItemView(title: "Rankings")
                    EventItemView(title: "Alliances")
                    EventItemView(title: "Awards")
                    EventItemView(title: "District Points")
                    EventItemView(title: "Teams")
                    EventItemView(title: "Insights")
                    EventItemView(title: "Media")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))

                Divider()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(event.displayNameWithYear)
                    .font(.headline)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .sharedBackgroundVisibility(.hidden)
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }
}

struct NavigationRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let count: String?

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

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
                    .font(.body.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
}
