//
//  EventListItem.swift
//  TBA
//
//  Created by Zachary Orr on 8/14/24.
//

import SwiftUI
import TBAAPI

struct EventListItem: View {
    private let event: Event

    init(event: Event) {
        self.event = event
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(event.displayName)
                        .lineLimit(1)
                    Spacer()
                }
                .foregroundColor(.primary)
                HStack(spacing: 0) {
                    if let location = event.displayLocation {
                        Text(location)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(event.displayDates)
                        .lineLimit(1)
                }
                .foregroundColor(.secondary)
                .font(.subheadline)
            }
            Spacer()
            Image(systemName: "chevron.forward")
                .font(.callout)
                .fontWeight(.semibold)
                .tint(.secondary)
                .foregroundStyle(.secondary)
        }
    }
}
