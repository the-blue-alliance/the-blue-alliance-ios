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
                // TODO: Statbotics?
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }

}
