//
//  EventHeaderView.swift
//  TBA
//
//  Created by Zachary Orr on 11/17/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI

struct EventHeaderView: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // TODO: Should this be tappable?
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
            // TODO: We should support child events here too (division_keys/parent_event_key)
            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 4) {
                GridRow {
                    Image(systemName: "calendar")
                        .gridColumnAlignment(.center)
                        .foregroundStyle(.accent)
                    HStack(spacing: 8) {
                        Text(event.displayDates)
                        if let week = event.weekString, !event.isRemote {
                            Text(week)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accessoryColor)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                let mapPin = Image(systemName: "mappin")
                    .gridColumnAlignment(.center)
                    .foregroundStyle(.accent)
                if let mapURL = event.mapURL(provider: .apple), let location = event.displayLocationWithVenue {
                    GridRow {
                        mapPin
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(location)
                                .multilineTextAlignment(.leading)
                            Link(destination: mapURL) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else if let location = event.fullDisplayLocation {
                    GridRow {
                        mapPin
                        Text(location)
                            .multilineTextAlignment(.leading)
                    }
                }
                if let website = event.website, let url = URL(string: website) {
                    GridRow {
                        Image(systemName: "link")
                            .gridColumnAlignment(.center)
                            .foregroundStyle(.accent)
                        Link(destination: url) {
                            HStack(spacing: 4) {
                                Text(website)
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                            }
                        }
                    }
                }
                // TODO: Statbotics?
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .imageScale(.medium)
        }
    }
}
