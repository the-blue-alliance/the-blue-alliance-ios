//
//  EventsView.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import TBAAPI
import SwiftUI
import Collections

struct EventsView: View {

    private var events: OrderedDictionary<String, [Event]>

    init(events: [Event], firstEventSortKeyPathComparator: KeyPathComparator<Event> = KeyPathComparator(\Event.hybridType), sectionKey: (Event) -> String = \.hybridType) {
        self.init(events: events, firstEventSortKeyPathComparators: [firstEventSortKeyPathComparator], sectionKey: sectionKey)
    }

    init(events: [Event], firstEventSortKeyPathComparators: [KeyPathComparator<Event>], sectionKey: (Event) -> String = \.hybridType) {
        let events = events.sorted(using: firstEventSortKeyPathComparators + [
            KeyPathComparator(\.startDate),
            KeyPathComparator(\.endDate),
            KeyPathComparator(\.name)
        ])
        self.events = OrderedDictionary(grouping: events, by: sectionKey)
    }

    var body: some View {
        List {
            if events.keys.count > 1 {
                ForEach(events.keys, id: \.self) { sectionKey in
                    Section(sectionKey) {
                        let events = self.events[sectionKey] ?? []
                        EventsList(events: events)
                    }
                }
            } else if events.keys.count == 1 {
                let events = self.events[events.keys.first!] ?? []
                EventsList(events: events)
            }
        }
        /*
        ScrollViewReader { reader in
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(events.keys, id: \.self) { sectionKey in
                        Section {
                            ForEach(events[sectionKey]!, id: \.key) { event in
                                VStack() {
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
                .background(Color(UIColor.systemGroupedBackground))
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
        */
    }
}

private struct EventsList: View {

    @State var events: [Event]

    var body: some View {
        ForEach(events, id: \.key) { event in
            NavigationLink(value: event) {
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
                }
            }
        }
    }
}
