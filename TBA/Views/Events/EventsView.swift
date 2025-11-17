//
//  EventsView.swift
//  TBA
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Collections
import SwiftUI
import TBAAPI

struct EventsView: View {
    private var events: OrderedDictionary<String, [Event]>

    init(events: [Event], firstEventSortKeyPathComparator: KeyPathComparator<Event> = KeyPathComparator(\Event.hybridType), sectionKey: (Event) -> String = \.hybridType) {
        self.init(events: events, firstEventSortKeyPathComparators: [firstEventSortKeyPathComparator], sectionKey: sectionKey)
    }

    init(events: [Event], firstEventSortKeyPathComparators: [KeyPathComparator<Event>], sectionKey: (Event) -> String = \.hybridType) {
        let events = events.sorted(using: firstEventSortKeyPathComparators + [
            KeyPathComparator(\.startDate),
            KeyPathComparator(\.endDate),
            KeyPathComparator(\.name),
        ])
        self.events = OrderedDictionary(grouping: events, by: sectionKey)
    }

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(events.keys, id: \.self) { sectionKey in
                        Section {
                            ForEach(events[sectionKey]!, id: \.key) { event in
                                VStack {
                                    Spacer()
                                    NavigationLink(value: event) {
                                        EventListItem(event: event)
                                    }
                                    .padding(.trailing)
                                    Divider()
                                }
                                .padding(.leading)
                            }
                        } header: {
                            EventListHeader(title: sectionKey)
                        }
                        .textCase(nil) // Will uppercase by default
                        // .listRowBackground(Color.systemBackground)
                        .listSectionSpacing(0)
                    }
                }
            }
            .onChange(of: events) {
                guard let firstSection = events.keys.first else {
                    return
                }
                withAnimation {
                    reader.scrollTo(firstSection, anchor: .top)
                }
            }
            .listStyle(.plain)
            .listSectionSpacing(0)
        }
    }
}

struct EventListHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.leading)
                .padding([.top, .bottom], 5)
            Spacer()
        }
        .background(Color(UIColor.tableViewHeaderColor))
    }
}

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
