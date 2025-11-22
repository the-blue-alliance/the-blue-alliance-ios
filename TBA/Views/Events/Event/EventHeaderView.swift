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

            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 4) {
                GridRow {
                    Image(systemName: "calendar")
                        .gridColumnAlignment(.center)
                    Text(event.displayDates)
                }
                if let location = event.displayLocation {
                    GridRow {
                        Image(systemName: "mappin")
                            .gridColumnAlignment(.center)
                        Text(location)
                    }
                }
                if let website = event.website, let url = URL(string: website) {
                    GridRow {
                        Image(systemName: "link")
                            .gridColumnAlignment(.center)
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
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}
