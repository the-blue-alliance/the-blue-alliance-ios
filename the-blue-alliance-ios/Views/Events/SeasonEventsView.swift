//
//  EventsView.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import TBAAPI
import SwiftUI

struct SeasonEventsView: View {

    @Environment(\.api) private var api
    @Environment(\.status) private var status

    @State var year: Int?

    private var eventsByWeek: [EventWeek: [SeasonEvent]]? {
        events?.groupedByWeek()
    }
    @State var eventWeek: EventWeek?
    @State private var events: [SeasonEvent]? {
        didSet {
            eventWeek = events?.nextOrFirstEvent()?.eventWeek
        }
    }
    private var eventsForWeek: [Event]? {
        // TODO: We'll probably want some sort of error state in here...
        guard let eventWeek else { return nil }
        guard let eventsByWeek else { return nil }
        return eventsByWeek[eventWeek]?.map(\.event)
    }

    @State private var isInitialLoading = false
    @State private var error: Error?

    var body: some View {
        EventsView(events: events?.map { $0.event } ?? [])
            .loadingNoData(
                isInitialLoading,
                data: events,
                title: "No Events")
            .refreshable {
                await refreshEvents()
            }
            .onAppear {
                if year == nil {
                    year = status.currentSeason
                }
            }
            .onChange(of: year) {
                Task {
                    events = nil // Clear events when year changes
                    await refreshEvents() // Load events for the new year
                }
            }
            .navigationTitle("Events")
            .navigationDestination(for: Event.self) { event in
                EventView(event: event)
            }
            .toolbar {
                /*
                ToolbarItem(placement: .principal) {
                    YearWeekHeaderView(yearWeek: $yearWeek, showYearWeekSelect: $showYearWeekSelect)
                }
                */
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gear") {
                        // TODO: Show Settings in a sheet
                    }
                    // .tint(.accentYellow)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        let years = Array((1992...2025).reversed())
                        Picker("Year", selection: $year) {
                            ForEach(years, id: \.self) { year in
                                Text(String(year))
                                    .tag(year)
                            }
                        }
                    } label: {
                        let title = {
                            guard let year = year else {
                                return "----"
                            }
                            return String(year)
                        }()
                        Label(title, systemImage: "chevron.down")
                    }
                    .menuStyle(.button)
                }
            }
    }

    private func refreshEvents() async {
        guard let year = year else { return }
        error = nil
        if events == nil {
            isInitialLoading = true
        }
        defer { isInitialLoading = false }
        do {
            let response = try await api.getEventsByYear(path: .init(year: year))
            events = try response.ok.body.json.compactMap { SeasonEvent(event: $0) }
        } catch {
            self.error = error
        }
    }
}
