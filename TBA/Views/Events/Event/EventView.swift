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
                VStack(alignment: .leading, spacing: 8) {
                    // TODO: We could use this to show if this is a part of a District?
                    if let district = event.district {
                        HStack(spacing: 8) {
                            Image(systemName: "circle.hexagongrid.fill")
                                // .font(.title2)
                                .tint(.accentColor)

                            Text("\(district.name) District")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text(event.displayNameWithYear)
                        .font(.title.bold())

                    VStack(alignment: .leading, spacing: 4) {
                        Label(event.displayDates, systemImage: "calendar")
                        if let location = event.displayLocation {
                            Label(location, systemImage: "mappin")
                        }
                        if let website = event.website, let url = URL(string: website) {
                            Button(action: {
                                UIApplication.shared.open(url)
                            }) {
                                HStack(spacing: 4) {
                                    Label(website, systemImage: "link")
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    /*
                    Text("An iOS app for accessing information about the FIRST Robotics Competition.")
                        .font(.body)
                        .foregroundColor(.secondary)

                    HStack(spacing: 20) {
                        Label("81 stars", systemImage: "star")
                        Label("24 forks", systemImage: "tuningfork")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    */
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: isStarred ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundColor(.yellow)
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button(action: {}) {
                        Label("Add to list", systemImage: "plus")
                            .font(.body.weight(.medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button(action: {}) {
                        Image(systemName: "tuningfork")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)

                // Navigation List
                VStack(spacing: 0) {
                    NavigationRowView(icon: "circle.circle", iconColor: .green, title: "Issues", count: "103")
                    NavigationRowView(icon: "arrow.left.arrow.right", iconColor: .blue, title: "Pull Requests", count: "2")
                    NavigationRowView(icon: "bubble.left.and.bubble.right", iconColor: .purple, title: "Discussions", count: "1")
                    NavigationRowView(icon: "play.circle", iconColor: .yellow, title: "Actions", count: nil)
                    NavigationRowView(icon: "cloud.fill", iconColor: .pink, title: "Agent Tasks", count: nil)
                    NavigationRowView(icon: "square.grid.3x2", iconColor: .gray, title: "Projects", count: "1")
                    NavigationRowView(icon: "tag", iconColor: .gray, title: "Releases", count: "52")
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
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
