//
//  EventsView.swift
//  TBA
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import TBAAPI
import SwiftUI

struct SeasonEventsView: View {

    @Environment(\.api) private var api
    @Environment(\.status) private var status

    @State private var yearWeek: YearWeek

    @State private var events: [SeasonEvent]? {
        didSet {
            if yearWeek.week == nil, let eventWeek = events?.nextOrFirstEvent()?.eventWeek {
                yearWeek = YearWeek(year: yearWeek.year, week: eventWeek)
            }
        }
    }
    private var eventsForWeek: [Event]? {
        // TODO: We'll probably want some sort of error state in here...
        guard let eventWeek = yearWeek.week else { return nil }
        guard let eventsByWeek = events?.groupedByWeek() else { return nil }
        return eventsByWeek[eventWeek]?.map(\.event)
    }

    @State private var isInitialLoading = false
    @State private var error: Error?
    @State private var showYearWeekSelect = false

    init(year: Year) {
        self.yearWeek = YearWeek(year: year, week: nil)
    }

    var body: some View {
        // TODO: Maybe this takes like... events, and an eventWeek?
        // It's a little wonky because `eventsForWeek` isn't State, so this
        // doesn't update automatically. However, I don't think we have
        // any kind of fallback error handling states in here
        EventsView(events: eventsForWeek ?? events?.map { $0.event } ?? [])
            .loadingNoData(
                isInitialLoading,
                data: events,
                title: "No events")
            .task {
                await refreshEvents()
            }
            .refreshable {
                await refreshEvents()
            }
            .onChange(of: yearWeek) {
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
                ToolbarItem(placement: .principal) {
                    YearWeekHeaderView(
                        yearWeek: $yearWeek,
                        showYearWeekSelect: $showYearWeekSelect
                    )
                }
                // .matchedTransitionSource(id: "transition-id", in: namespace)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gear") {
                        // TODO: Show Settings in a sheet
                    }
                    .tint(.accentYellow)
                }
            }
            .toolbarBackground(Color.navigationBarColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showYearWeekSelect) {
                let years = Array((1992...status.maxSeason).reversed())
                YearWeekSelectView(years: years, yearWeek: yearWeek) { yearWeek in
                    self.yearWeek = yearWeek
                }
                .presentationDetents([.medium, .large])
                .navigationTransition(.automatic)
                // .navigationTransition(.zoom(sourceID: "transition-id", in: namespace))
            }
    }

    private func refreshEvents() async {
        error = nil
        if events == nil {
            isInitialLoading = true
        }
        defer { isInitialLoading = false }
        do {
            let response = try await api.getEventsByYear(path: .init(year: yearWeek.year))
            events = try response.ok.body.json.compactMap { SeasonEvent(event: $0) }
        } catch {
            self.error = error
        }
    }
}
